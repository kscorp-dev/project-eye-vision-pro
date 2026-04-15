import Testing
import simd
@testable import EyeJourney

@Suite("GameEngine Tests")
struct GameEngineTests {

    @Test("초기 상태 확인")
    func initialState() {
        let engine = GameEngine()
        #expect(engine.state == .idle)
        #expect(engine.score == 0)
        #expect(engine.combo == 0)
        #expect(engine.progress == 0)
    }

    @Test("세션 시작 시 상태 변경")
    func startSession() {
        let engine = GameEngine()
        let waypoints = createTestWaypoints(count: 5)
        engine.startSession(waypoints: waypoints)

        #expect(engine.state == .playing)
        #expect(engine.currentWaypointIndex == 0)
        #expect(engine.score == 0)
    }

    @Test("웨이포인트 도달 시 점수 증가")
    func waypointReachedScoring() {
        let engine = GameEngine()
        let waypoints = createTestWaypoints(count: 5)
        engine.startSession(waypoints: waypoints)

        engine.onWaypointReached()
        #expect(engine.score > 0)
        #expect(engine.combo == 1)
        #expect(engine.currentWaypointIndex == 1)
    }

    @Test("콤보 시스템")
    func comboSystem() {
        let engine = GameEngine()
        let waypoints = createTestWaypoints(count: 10)
        engine.startSession(waypoints: waypoints)

        // 3연속 히트
        engine.onWaypointReached()
        engine.onWaypointReached()
        engine.onWaypointReached()
        #expect(engine.combo == 3)
        #expect(engine.maxCombo == 3)

        // 미스 → 콤보 리셋
        engine.onMissed()
        #expect(engine.combo == 0)
        #expect(engine.maxCombo == 3) // 최대 콤보는 유지

        // 다시 히트
        engine.onWaypointReached()
        #expect(engine.combo == 1)
    }

    @Test("모든 웨이포인트 완료 시 상태 변경")
    func sessionCompletion() {
        let engine = GameEngine()
        let waypoints = createTestWaypoints(count: 3)
        engine.startSession(waypoints: waypoints)

        engine.onWaypointReached()
        engine.onWaypointReached()
        engine.onWaypointReached()
        #expect(engine.state == .completed)
        #expect(engine.progress == 1.0)
    }

    @Test("일시정지/재개")
    func pauseResume() {
        let engine = GameEngine()
        let waypoints = createTestWaypoints(count: 5)
        engine.startSession(waypoints: waypoints)

        engine.pause()
        #expect(engine.state == .paused)

        engine.resume()
        #expect(engine.state == .playing)
    }

    @Test("진행률 계산")
    func progressCalculation() {
        let engine = GameEngine()
        let waypoints = createTestWaypoints(count: 4)
        engine.startSession(waypoints: waypoints)

        #expect(engine.progress == 0)

        engine.onWaypointReached()
        #expect(engine.progress == 0.25)

        engine.onWaypointReached()
        #expect(engine.progress == 0.5)
    }

    @Test("Smooth Pursuit 패턴 생성")
    func smoothPursuitPattern() {
        let center = SIMD3<Float>(0, 0, -1.5)
        let points = GameEngine.generateSmoothPursuitPattern(center: center, pointCount: 20)

        #expect(points.count == 20)
        // 모든 포인트가 center 근처에 있는지 확인
        for point in points {
            #expect(abs(point.x - center.x) <= 1.0)
            #expect(abs(point.z - center.z) <= 0.1)
        }
    }

    @Test("Saccade 패턴 - 최소 거리 보장")
    func saccadeMinDistance() {
        let center = SIMD3<Float>(0, 0, -1.5)
        let points = GameEngine.generateSaccadePattern(center: center, spread: 0.6, pointCount: 10)

        #expect(points.count == 10)
        // 연속된 포인트 간 최소 거리 확인
        for i in 1..<points.count {
            let dist = distance(points[i], points[i - 1])
            #expect(dist > 0.1, "연속 포인트 간 거리가 너무 가까움: \(dist)")
        }
    }

    @Test("Circular 패턴 생성")
    func circularPattern() {
        let center = SIMD3<Float>(0, 0, -1.5)
        let points = GameEngine.generateCircularPattern(center: center, radius: 0.4, pointCount: 24)

        #expect(points.count == 24)
    }

    @Test("Figure Eight 패턴 생성")
    func figureEightPattern() {
        let center = SIMD3<Float>(0, 0, -1.5)
        let points = GameEngine.generateFigureEightPattern(center: center, pointCount: 30)

        #expect(points.count == 30)
    }

    @Test("난이도 스케일링")
    func difficultyScaling() {
        let easy = DifficultyScaling.easy
        let normal = DifficultyScaling.normal
        let hard = DifficultyScaling.hard

        #expect(easy.speedMultiplier < normal.speedMultiplier)
        #expect(normal.speedMultiplier < hard.speedMultiplier)
        #expect(easy.scoreMultiplier < normal.scoreMultiplier)
    }

    @Test("분기 선택")
    func branchSelection() {
        let engine = GameEngine()
        let waypoints = createTestWaypoints(count: 5)
        engine.startSession(waypoints: waypoints)

        let options = [
            BranchOption(name: "해안", direction: .left, difficulty: .beginner, description: "해안 루트"),
            BranchOption(name: "산길", direction: .right, difficulty: .intermediate, description: "산 루트"),
        ]
        engine.presentBranch(options: options)
        #expect(engine.state == .branching)

        engine.selectBranch(options[0])
        #expect(engine.state == .playing)
    }

    // MARK: - Helpers

    private func createTestWaypoints(count: Int) -> [Waypoint] {
        (0..<count).map { i in
            Waypoint(
                latitude: 33.0 + Double(i) * 0.01,
                longitude: 126.0 + Double(i) * 0.01,
                orderIndex: i
            )
        }
    }
}
