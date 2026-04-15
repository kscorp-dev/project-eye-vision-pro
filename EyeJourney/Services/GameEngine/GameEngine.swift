import Foundation
import simd

/// 안구운동 게임의 핵심 로직을 관리하는 엔진
@Observable
final class GameEngine {
    // 게임 상태
    var state: GameState = .idle
    var currentWaypointIndex = 0
    var score = 0
    var combo = 0
    var maxCombo = 0

    // 가이드 포인트
    var activeGuidePosition: SIMD3<Float> = .zero
    var guidePositions: [SIMD3<Float>] = []
    var guidePattern: ExerciseType = .smoothPursuit

    // 타이밍
    var elapsedTime: TimeInterval = 0
    var reactionTimes: [TimeInterval] = []
    private var lastWaypointReachedTime: Date?

    // 진행도
    var progress: Float {
        guard !guidePositions.isEmpty else { return 0 }
        return Float(currentWaypointIndex) / Float(guidePositions.count)
    }

    var averageReactionTime: TimeInterval {
        guard !reactionTimes.isEmpty else { return 0 }
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }

    // MARK: - 게임 제어

    /// 새로운 운동 세션 시작
    func startSession(waypoints: [Waypoint]) {
        guidePositions = waypoints.sorted(by: { $0.orderIndex < $1.orderIndex })
            .map(\.position3D)
        currentWaypointIndex = 0
        score = 0
        combo = 0
        maxCombo = 0
        elapsedTime = 0
        reactionTimes = []
        lastWaypointReachedTime = Date()

        if let first = guidePositions.first {
            activeGuidePosition = first
        }

        state = .playing
    }

    /// 시선이 현재 가이드 포인트에 도달했을 때
    func onWaypointReached() {
        guard state == .playing else { return }

        // 반응 시간 기록
        if let lastTime = lastWaypointReachedTime {
            let reaction = Date().timeIntervalSince(lastTime)
            reactionTimes.append(reaction)
        }
        lastWaypointReachedTime = Date()

        // 점수 계산
        combo += 1
        if combo > maxCombo { maxCombo = combo }
        let comboMultiplier = min(combo, 5)
        score += 100 * comboMultiplier

        // 다음 웨이포인트
        currentWaypointIndex += 1
        if currentWaypointIndex < guidePositions.count {
            activeGuidePosition = guidePositions[currentWaypointIndex]
        } else {
            state = .completed
        }
    }

    /// 시선이 빗나갔을 때
    func onMissed() {
        combo = 0
    }

    /// 세션 일시정지
    func pause() {
        guard state == .playing else { return }
        state = .paused
    }

    /// 세션 재개
    func resume() {
        guard state == .paused else { return }
        state = .playing
        lastWaypointReachedTime = Date()
    }

    /// 세션 종료
    func endSession() {
        state = .completed
    }

    // MARK: - 가이드 포인트 패턴 생성

    /// 수평 추적 패턴 생성
    static func generateSmoothPursuitPattern(
        center: SIMD3<Float>,
        amplitude: Float = 0.5,
        pointCount: Int = 20
    ) -> [SIMD3<Float>] {
        (0..<pointCount).map { i in
            let t = Float(i) / Float(pointCount - 1)
            let x = center.x + sin(t * .pi * 2) * amplitude
            let y = center.y + cos(t * .pi * 4) * amplitude * 0.3
            return SIMD3<Float>(x, y, center.z)
        }
    }

    /// 빠른 시선 이동(Saccade) 패턴 생성
    static func generateSaccadePattern(
        center: SIMD3<Float>,
        spread: Float = 0.6,
        pointCount: Int = 15
    ) -> [SIMD3<Float>] {
        (0..<pointCount).map { _ in
            let x = center.x + Float.random(in: -spread...spread)
            let y = center.y + Float.random(in: -spread * 0.6...spread * 0.6)
            let z = center.z + Float.random(in: -0.1...0.1)
            return SIMD3<Float>(x, y, z)
        }
    }

    /// 원형 추적 패턴 생성
    static func generateCircularPattern(
        center: SIMD3<Float>,
        radius: Float = 0.4,
        pointCount: Int = 24
    ) -> [SIMD3<Float>] {
        (0..<pointCount).map { i in
            let angle = Float(i) / Float(pointCount) * .pi * 2
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            return SIMD3<Float>(x, y, center.z)
        }
    }

    /// 초점 전환(Vergence) 패턴 생성
    static func generateVergencePattern(
        center: SIMD3<Float>,
        nearDistance: Float = -0.5,
        farDistance: Float = -2.0,
        pointCount: Int = 10
    ) -> [SIMD3<Float>] {
        (0..<pointCount).map { i in
            let isNear = i % 2 == 0
            let z = isNear ? nearDistance : farDistance
            let offsetX = Float.random(in: -0.1...0.1)
            let offsetY = Float.random(in: -0.1...0.1)
            return SIMD3<Float>(center.x + offsetX, center.y + offsetY, z)
        }
    }
}

enum GameState: String {
    case idle
    case playing
    case paused
    case completed
}
