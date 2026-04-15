import SwiftUI
import simd

@Observable
final class ExerciseViewModel {
    let program: ExerciseProgram

    // 게임 엔진
    private let gameEngine = GameEngine()
    private let eyeTracking = EyeTrackingService()

    // 카운트다운
    var countdown: Int = 3

    // 현재 상태
    var gameState: GameState { gameEngine.state }
    var score: Int { gameEngine.score }
    var combo: Int { gameEngine.combo }
    var maxCombo: Int { gameEngine.maxCombo }
    var progress: Float { gameEngine.progress }
    var guidePosition: SIMD3<Float> { gameEngine.activeGuidePosition }
    var currentWaypointIndex: Int { gameEngine.currentWaypointIndex }

    // 현재 페이즈
    private var currentPhaseIndex = 0
    var currentPhase: ExercisePhase {
        program.phases[min(currentPhaseIndex, program.phases.count - 1)]
    }
    var currentExerciseType: ExerciseType { currentPhase.exerciseType }
    var currentGuideType: GuideType {
        switch currentExerciseType {
        case .smoothPursuit: return .butterfly
        case .saccade: return .star
        case .vergence: return .firefly
        case .circularTracking: return .bird
        }
    }

    var currentPhaseDescription: String { currentPhase.description }
    var dwellProgress: Float = 0

    // 타이밍
    private var startTime: Date?
    var elapsedTime: TimeInterval {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }
    var elapsedTimeFormatted: String {
        let mins = Int(elapsedTime) / 60
        let secs = Int(elapsedTime) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var totalWaypoints: Int { program.totalWaypoints }

    var accuracyText: String {
        String(format: "%.1f%%", eyeTracking.accuracy * 100)
    }

    init(program: ExerciseProgram) {
        self.program = program
    }

    // MARK: - Lifecycle

    /// 카운트다운 시작
    func startCountdown() async {
        for i in stride(from: 3, through: 1, by: -1) {
            countdown = i
            try? await Task.sleep(for: .seconds(1))
        }
        await startExercise()
    }

    /// 운동 시작
    private func startExercise() async {
        startTime = Date()
        let points = generatePointsForPhase(currentPhase)
        let waypoints = points.enumerated().map { index, pos in
            Waypoint(
                latitude: Double(pos.z) * -100,
                longitude: Double(pos.x) * 100,
                altitude: Double(pos.y) * 1000,
                guideType: currentGuideType,
                exercisePattern: currentExerciseType,
                orderIndex: index
            )
        }
        gameEngine.startSession(waypoints: waypoints)

        // 아이트래킹 시작
        await eyeTracking.start()

        // 추적 루프
        await runTrackingLoop()
    }

    /// 시선 추적 루프
    private func runTrackingLoop() async {
        while gameEngine.state == .playing {
            await eyeTracking.updateGaze()

            let isLooking = eyeTracking.isLookingAt(
                targetPosition: gameEngine.activeGuidePosition,
                threshold: 0.15
            )

            if isLooking {
                dwellProgress += Float(1.0 / 60.0 / currentPhase.speed)
                if dwellProgress >= 1.0 {
                    gameEngine.onWaypointReached()
                    eyeTracking.recordHit()
                    dwellProgress = 0

                    // 현재 페이즈 완료 확인
                    if gameEngine.state == .completed {
                        await advancePhase()
                    }
                }
            } else {
                dwellProgress = max(0, dwellProgress - Float(2.0 / 60.0))
                if dwellProgress == 0 {
                    eyeTracking.recordMiss()
                    gameEngine.onMissed()
                }
            }

            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    /// 다음 페이즈로 전환
    private func advancePhase() async {
        currentPhaseIndex += 1
        if currentPhaseIndex < program.phases.count {
            let nextPhase = program.phases[currentPhaseIndex]
            let points = generatePointsForPhase(nextPhase)
            let waypoints = points.enumerated().map { index, pos in
                Waypoint(
                    latitude: Double(pos.z) * -100,
                    longitude: Double(pos.x) * 100,
                    altitude: Double(pos.y) * 1000,
                    guideType: currentGuideType,
                    exercisePattern: nextPhase.exerciseType,
                    orderIndex: index
                )
            }
            gameEngine.startSession(waypoints: waypoints)
            await runTrackingLoop()
        }
        // 모든 페이즈 완료
    }

    // MARK: - Controls

    func pause() { gameEngine.pause() }
    func resume() {
        gameEngine.resume()
        Task { await runTrackingLoop() }
    }

    // MARK: - Pattern Generation

    private func generatePointsForPhase(_ phase: ExercisePhase) -> [SIMD3<Float>] {
        let center = SIMD3<Float>(0, 0, -1.5)
        switch phase.exerciseType {
        case .smoothPursuit:
            return GameEngine.generateSmoothPursuitPattern(center: center, pointCount: phase.pointCount)
        case .saccade:
            return GameEngine.generateSaccadePattern(center: center, pointCount: phase.pointCount)
        case .circularTracking:
            return GameEngine.generateCircularPattern(center: center, pointCount: phase.pointCount)
        case .vergence:
            return GameEngine.generateVergencePattern(center: center, pointCount: phase.pointCount)
        }
    }
}
