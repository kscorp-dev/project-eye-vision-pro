import SwiftUI
import SwiftData
import simd

@Observable
final class ExerciseViewModel {
    let program: ExerciseProgram

    // 게임 엔진
    private let gameEngine = GameEngine()
    private let eyeTracking = EyeTrackingService()
    private let headTracking = HeadTrackingService()

    // 세션 저장 완료 여부
    var sessionSaved = false

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
        case .neckFlexion, .neckRotation, .neckLateralTilt, .neckCircle:
            return .petal  // 목 운동은 꽃잎 가이드
        }
    }

    var currentPhaseDescription: String { currentPhase.description }
    var dwellProgress: Float = 0

    /// Look+Pinch: dwell이 완료되어 핀치 대기 중인지 여부 (눈 운동 전용)
    var waitingForPinch: Bool = false

    // 목 운동 상태
    var isNeckExercise: Bool { currentExerciseType.isNeckExercise }
    var currentHeadPitch: Float { headTracking.pitch }
    var currentHeadYaw: Float { headTracking.yaw }
    var currentHeadRoll: Float { headTracking.roll }
    var neckSafetyWarning: String? { headTracking.safetyWarning }

    /// 목 운동의 현재 목표 각도 (x=yaw, y=pitch, z=roll)
    var neckTargetAngles: SIMD3<Float> {
        guard !neckAngleTargets.isEmpty,
              currentWaypointIndex < neckAngleTargets.count else {
            return .zero
        }
        return neckAngleTargets[currentWaypointIndex]
    }
    private var neckAngleTargets: [SIMD3<Float>] = []

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
        if isNeckExercise {
            return String(format: "%.1f%%", headTracking.accuracy * 100)
        }
        return String(format: "%.1f%%", eyeTracking.accuracy * 100)
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
        let phase = currentPhase

        if phase.exerciseType.isNeckExercise {
            await startNeckExercise(phase: phase)
        } else {
            await startEyeExercise(phase: phase)
        }
    }

    /// 눈 운동 시작
    private func startEyeExercise(phase: ExercisePhase) async {
        let points = generatePointsForPhase(phase)
        let waypoints = points.enumerated().map { index, pos in
            Waypoint(
                latitude: Double(pos.z) * -100,
                longitude: Double(pos.x) * 100,
                altitude: Double(pos.y) * 1000,
                guideType: currentGuideType,
                exercisePattern: phase.exerciseType,
                orderIndex: index
            )
        }
        gameEngine.startSession(waypoints: waypoints)
        await eyeTracking.start()
        await runEyeTrackingLoop()
    }

    /// 목 운동 시작
    private func startNeckExercise(phase: ExercisePhase) async {
        neckAngleTargets = generateNeckAnglesForPhase(phase)

        // 각도 목표를 위치로 변환하여 GameEngine에 전달 (진행도 추적용)
        let waypoints = neckAngleTargets.enumerated().map { index, angles in
            Waypoint(
                latitude: Double(angles.y) * 100,
                longitude: Double(angles.x) * 100,
                altitude: 0,
                guideType: currentGuideType,
                exercisePattern: phase.exerciseType,
                orderIndex: index
            )
        }
        gameEngine.startSession(waypoints: waypoints)

        await headTracking.start()
        // 캘리브레이션: 현재 위치를 기준점으로
        try? await Task.sleep(for: .milliseconds(500))
        await headTracking.calibrate()

        await runNeckTrackingLoop()
    }

    /// 시선 추적 루프 (Look+Pinch 방식)
    /// dwell이 100% 차면 waitingForPinch=true → 사용자 핀치로 확인
    private func runEyeTrackingLoop() async {
        while gameEngine.state == .playing {
            // 핀치 대기 중이면 추적만 유지하고 진행하지 않음
            if waitingForPinch {
                try? await Task.sleep(for: .milliseconds(16))
                continue
            }

            await eyeTracking.updateGaze()

            let isLooking = eyeTracking.isLookingAt(
                targetPosition: gameEngine.activeGuidePosition,
                threshold: 0.15
            )

            if isLooking {
                dwellProgress += Float(1.0 / 60.0 / currentPhase.speed)
                if dwellProgress >= 1.0 {
                    dwellProgress = 1.0
                    waitingForPinch = true
                }
            } else {
                // 시선이 벗어나면 핀치 대기도 해제
                if dwellProgress > 0 {
                    dwellProgress = max(0, dwellProgress - Float(2.0 / 60.0))
                }
                if dwellProgress == 0 {
                    eyeTracking.recordMiss()
                    gameEngine.onMissed()
                }
            }

            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    /// 사용자 핀치(탭) 제스처로 웨이포인트 확인 (Look+Pinch)
    func confirmWaypoint() {
        guard waitingForPinch else { return }
        waitingForPinch = false
        dwellProgress = 0

        gameEngine.onWaypointReached()
        eyeTracking.recordHit()

        if gameEngine.state == .completed {
            Task { await advancePhase() }
        }
    }

    /// 목 운동 추적 루프
    private func runNeckTrackingLoop() async {
        while gameEngine.state == .playing {
            await headTracking.update()

            guard currentWaypointIndex < neckAngleTargets.count else { break }
            let target = neckAngleTargets[currentWaypointIndex]

            // 목 운동은 더 넓은 허용치 (12°) 사용
            let threshold: Float = 12 * .pi / 180
            let isAtTarget = headTracking.isAtTarget(angles: target, threshold: threshold)

            // 안전 범위 확인
            if !headTracking.isInSafeRange {
                // 범위 초과 시 진행을 멈추고 경고만 표시
                try? await Task.sleep(for: .milliseconds(16))
                continue
            }

            if isAtTarget {
                // 목 운동은 더 느린 dwell (안전하게)
                dwellProgress += Float(1.0 / 60.0 / max(currentPhase.speed, 0.5))
                if dwellProgress >= 1.0 {
                    gameEngine.onWaypointReached()
                    headTracking.recordHit()
                    dwellProgress = 0

                    if gameEngine.state == .completed {
                        await advancePhase()
                    }
                }
            } else {
                dwellProgress = max(0, dwellProgress - Float(1.5 / 60.0))
                if dwellProgress == 0 {
                    headTracking.recordMiss()
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

            if nextPhase.exerciseType.isNeckExercise {
                await startNeckExercise(phase: nextPhase)
            } else {
                await startEyeExercise(phase: nextPhase)
            }
        }
        // 모든 페이즈 완료
    }

    // MARK: - Controls

    func pause() { gameEngine.pause() }
    func resume() {
        gameEngine.resume()
        Task {
            if currentExerciseType.isNeckExercise {
                await runNeckTrackingLoop()
            } else {
                await runEyeTrackingLoop()
            }
        }
    }

    func stop() {
        eyeTracking.stop()
        headTracking.stop()
        gameEngine.endSession()
    }

    // MARK: - Eye Exercise Pattern Generation

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
        case .neckFlexion, .neckRotation, .neckLateralTilt, .neckCircle:
            return [] // 목 운동은 generateNeckAnglesForPhase 사용
        }
    }

    // MARK: - Neck Exercise Pattern Generation

    private func generateNeckAnglesForPhase(_ phase: ExercisePhase) -> [SIMD3<Float>] {
        switch phase.exerciseType {
        case .neckFlexion:
            return GameEngine.generateNeckFlexionPattern(pointCount: phase.pointCount)
        case .neckRotation:
            return GameEngine.generateNeckRotationPattern(pointCount: phase.pointCount)
        case .neckLateralTilt:
            return GameEngine.generateNeckLateralTiltPattern(pointCount: phase.pointCount)
        case .neckCircle:
            return GameEngine.generateNeckCirclePattern(pointCount: phase.pointCount)
        default:
            return []
        }
    }

    // MARK: - Events & Branches

    var activeEvent: GameEvent? { gameEngine.activeEvent }
    var activeBranch: BranchChoice? { gameEngine.activeBranch }

    func dismissEvent() {
        gameEngine.completeEvent()
    }

    func selectBranch(_ option: BranchOption) {
        gameEngine.selectBranch(option)
    }

    // MARK: - Session Persistence

    func saveSession(modelContext: ModelContext, routeId: UUID? = nil) {
        guard !sessionSaved else { return }
        sessionSaved = true

        let session = ExerciseSession(routeId: routeId ?? UUID())
        session.completedAt = Date()
        session.totalPoints = score
        session.accuracy = isNeckExercise
            ? Double(headTracking.accuracy)
            : Double(eyeTracking.accuracy)
        session.averageReactionTime = gameEngine.averageReactionTime
        modelContext.insert(session)

        // 프로필 업데이트
        let descriptor = FetchDescriptor<UserProfile>()
        let profile: UserProfile
        if let existing = try? modelContext.fetch(descriptor).first {
            profile = existing
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
        }
        profile.updateStreak()
        profile.totalSessions += 1
        profile.totalExerciseTime += elapsedTime

        try? modelContext.save()
    }
}
