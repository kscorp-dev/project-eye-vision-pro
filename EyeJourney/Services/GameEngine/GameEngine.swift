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

    // 난이도
    var difficulty: DifficultyScaling = .normal

    // 이벤트
    var activeEvent: GameEvent?
    var eventHistory: [GameEvent] = []

    // 분기 선택
    var activeBranch: BranchChoice?

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

    func startSession(waypoints: [Waypoint]) {
        guidePositions = waypoints.sorted(by: { $0.orderIndex < $1.orderIndex })
            .map(\.position3D)
        currentWaypointIndex = 0
        score = 0
        combo = 0
        maxCombo = 0
        elapsedTime = 0
        reactionTimes = []
        eventHistory = []
        activeEvent = nil
        activeBranch = nil
        lastWaypointReachedTime = Date()

        if let first = guidePositions.first {
            activeGuidePosition = first
        }

        state = .playing
    }

    /// 시선이 현재 가이드 포인트에 도달
    func onWaypointReached() {
        guard state == .playing else { return }

        // 반응 시간 기록
        if let lastTime = lastWaypointReachedTime {
            let reaction = Date().timeIntervalSince(lastTime)
            reactionTimes.append(reaction)
        }
        lastWaypointReachedTime = Date()

        // 점수 계산 (정확도 + 콤보 + 난이도 보너스)
        combo += 1
        if combo > maxCombo { maxCombo = combo }
        let baseScore = 100
        let comboBonus = min(combo, 10) * 20
        let difficultyBonus = Int(difficulty.scoreMultiplier * 50)
        score += baseScore + comboBonus + difficultyBonus

        // 랜덤 이벤트 체크
        checkForEvent()

        // 적응형 난이도 조정
        adjustDifficulty()

        // 다음 웨이포인트
        currentWaypointIndex += 1
        if currentWaypointIndex < guidePositions.count {
            activeGuidePosition = guidePositions[currentWaypointIndex]
        } else {
            state = .completed
        }
    }

    func onMissed() {
        combo = 0
        adjustDifficulty()
    }

    func pause() {
        guard state == .playing else { return }
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        state = .playing
        lastWaypointReachedTime = Date()
    }

    func endSession() {
        state = .completed
    }

    // MARK: - 분기 선택 (갈림길)

    /// 갈림길 표시
    func presentBranch(options: [BranchOption]) {
        activeBranch = BranchChoice(options: options)
        state = .branching
    }

    /// 시선으로 분기 선택 완료
    func selectBranch(_ option: BranchOption) {
        activeBranch = nil
        score += 50 // 선택 보너스
        state = .playing
    }

    // MARK: - 랜덤 이벤트

    private func checkForEvent() {
        // 5개 포인트마다 20% 확률로 보너스 이벤트
        guard currentWaypointIndex > 0,
              currentWaypointIndex % 5 == 0,
              Float.random(in: 0...1) < 0.2 else { return }

        let events: [GameEvent.EventType] = [.bonusAnimal, .speedChallenge, .hiddenStamp]
        let type = events.randomElement() ?? .bonusAnimal
        let event = GameEvent(type: type, waypointIndex: currentWaypointIndex)
        activeEvent = event
        eventHistory.append(event)
    }

    /// 이벤트 완료 처리
    func completeEvent() {
        guard let event = activeEvent else { return }
        switch event.type {
        case .bonusAnimal:
            score += 300
        case .speedChallenge:
            score += 500
        case .hiddenStamp:
            score += 200
        }
        activeEvent = nil
    }

    // MARK: - 적응형 난이도

    private func adjustDifficulty() {
        let recentCount = min(reactionTimes.count, 5)
        guard recentCount >= 3 else { return }

        let recent = reactionTimes.suffix(recentCount)
        let avgRecent = recent.reduce(0, +) / Double(recentCount)

        // 반응 시간과 콤보 기반으로 난이도 조정
        if avgRecent < 1.0 && combo >= 5 {
            difficulty = difficulty.harder
        } else if avgRecent > 3.0 || combo == 0 {
            difficulty = difficulty.easier
        }
    }

    // MARK: - 패턴 생성

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

    static func generateSaccadePattern(
        center: SIMD3<Float>,
        spread: Float = 0.6,
        pointCount: Int = 15
    ) -> [SIMD3<Float>] {
        // 이전 위치에서 최소 거리 보장하여 실제 saccade 유도
        var points: [SIMD3<Float>] = []
        var lastPoint = center
        for _ in 0..<pointCount {
            var newPoint: SIMD3<Float>
            repeat {
                newPoint = SIMD3<Float>(
                    center.x + Float.random(in: -spread...spread),
                    center.y + Float.random(in: -spread * 0.6...spread * 0.6),
                    center.z + Float.random(in: -0.1...0.1)
                )
            } while distance(newPoint, lastPoint) < spread * 0.4
            points.append(newPoint)
            lastPoint = newPoint
        }
        return points
    }

    static func generateCircularPattern(
        center: SIMD3<Float>,
        radius: Float = 0.4,
        pointCount: Int = 24
    ) -> [SIMD3<Float>] {
        (0..<pointCount).map { i in
            let angle = Float(i) / Float(pointCount) * .pi * 2
            // 나선형으로 약간의 변화를 추가
            let r = radius * (1.0 + sin(Float(i) * 0.3) * 0.15)
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            return SIMD3<Float>(x, y, center.z)
        }
    }

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

    /// 8자 패턴 (종합 운동)
    static func generateFigureEightPattern(
        center: SIMD3<Float>,
        size: Float = 0.4,
        pointCount: Int = 30
    ) -> [SIMD3<Float>] {
        (0..<pointCount).map { i in
            let t = Float(i) / Float(pointCount) * .pi * 2
            let x = center.x + sin(t) * size
            let y = center.y + sin(t * 2) * size * 0.5
            return SIMD3<Float>(x, y, center.z)
        }
    }
}

// MARK: - Supporting Types

enum GameState: String {
    case idle, playing, paused, completed, branching
}

/// 적응형 난이도 스케일링
struct DifficultyScaling {
    var speedMultiplier: Float    // 포인트 이동 속도 배율
    var thresholdReduction: Float // dwell threshold 감소
    var scoreMultiplier: Float    // 점수 배율

    static let easy = DifficultyScaling(speedMultiplier: 0.7, thresholdReduction: 0, scoreMultiplier: 0.8)
    static let normal = DifficultyScaling(speedMultiplier: 1.0, thresholdReduction: 0, scoreMultiplier: 1.0)
    static let hard = DifficultyScaling(speedMultiplier: 1.3, thresholdReduction: 0.03, scoreMultiplier: 1.5)
    static let expert = DifficultyScaling(speedMultiplier: 1.6, thresholdReduction: 0.05, scoreMultiplier: 2.0)

    var harder: DifficultyScaling {
        switch scoreMultiplier {
        case ..<0.9: return .normal
        case ..<1.1: return .hard
        default: return .expert
        }
    }

    var easier: DifficultyScaling {
        switch scoreMultiplier {
        case 1.6...: return .hard
        case 1.1...: return .normal
        default: return .easy
        }
    }
}

/// 게임 내 이벤트
struct GameEvent: Identifiable {
    let id = UUID()
    let type: EventType
    let waypointIndex: Int
    let timestamp = Date()

    enum EventType: String {
        case bonusAnimal = "동물 발견"
        case speedChallenge = "스피드 챌린지"
        case hiddenStamp = "히든 스탬프"

        var iconName: String {
            switch self {
            case .bonusAnimal: return "hare.fill"
            case .speedChallenge: return "bolt.fill"
            case .hiddenStamp: return "stamp.fill"
            }
        }

        var bonusText: String {
            switch self {
            case .bonusAnimal: return "+300"
            case .speedChallenge: return "+500"
            case .hiddenStamp: return "+200"
            }
        }
    }
}

/// 갈림길 선택
struct BranchChoice {
    let options: [BranchOption]
    var selectedIndex: Int?
    var dwellTimes: [Float]

    init(options: [BranchOption]) {
        self.options = options
        self.dwellTimes = Array(repeating: 0, count: options.count)
    }
}

struct BranchOption: Identifiable {
    let id = UUID()
    let name: String
    let direction: BranchDirection
    let difficulty: Difficulty
    let description: String
}

enum BranchDirection: String {
    case left = "왼쪽"
    case right = "오른쪽"
    case forward = "직진"

    var iconName: String {
        switch self {
        case .left: return "arrow.turn.up.left"
        case .right: return "arrow.turn.up.right"
        case .forward: return "arrow.up"
        }
    }
}
