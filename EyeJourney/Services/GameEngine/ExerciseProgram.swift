import Foundation
import simd

/// 미리 정의된 운동 프로그램
struct ExerciseProgram {
    let name: String
    let nameLocalized: String
    let duration: TimeInterval
    let phases: [ExercisePhase]

    var totalWaypoints: Int {
        phases.reduce(0) { $0 + $1.pointCount }
    }
}

struct ExercisePhase {
    let exerciseType: ExerciseType
    let pointCount: Int
    let speed: Float        // 포인트 이동 속도 (1.0 = 보통)
    let description: String
}

// MARK: - 기본 제공 프로그램

extension ExerciseProgram {
    /// 모닝 스트레칭 (3분)
    static let morningStretch = ExerciseProgram(
        name: "Morning Stretch",
        nameLocalized: "모닝 스트레칭",
        duration: 180,
        phases: [
            ExercisePhase(
                exerciseType: .smoothPursuit,
                pointCount: 16,
                speed: 0.7,
                description: "수평선을 따라 천천히 시선을 이동하세요"
            ),
            ExercisePhase(
                exerciseType: .vergence,
                pointCount: 8,
                speed: 0.5,
                description: "가까운 곳과 먼 곳을 번갈아 바라보세요"
            ),
            ExercisePhase(
                exerciseType: .circularTracking,
                pointCount: 12,
                speed: 0.6,
                description: "원을 그리며 시선을 이동하세요"
            )
        ]
    )

    /// 점심 리프레시 (5분)
    static let lunchRefresh = ExerciseProgram(
        name: "Lunch Refresh",
        nameLocalized: "점심 리프레시",
        duration: 300,
        phases: [
            ExercisePhase(
                exerciseType: .saccade,
                pointCount: 20,
                speed: 1.2,
                description: "빠르게 나타나는 포인트를 포착하세요"
            ),
            ExercisePhase(
                exerciseType: .circularTracking,
                pointCount: 24,
                speed: 1.0,
                description: "새떼의 비행 패턴을 따라가세요"
            ),
            ExercisePhase(
                exerciseType: .smoothPursuit,
                pointCount: 16,
                speed: 1.0,
                description: "나비의 이동 경로를 추적하세요"
            ),
            ExercisePhase(
                exerciseType: .vergence,
                pointCount: 10,
                speed: 0.8,
                description: "꽃에서 산봉우리로 시선을 전환하세요"
            )
        ]
    )

    /// 풀 코스 여행 (10분)
    static let fullCourse = ExerciseProgram(
        name: "Full Course Journey",
        nameLocalized: "풀 코스 여행",
        duration: 600,
        phases: [
            ExercisePhase(
                exerciseType: .smoothPursuit,
                pointCount: 24,
                speed: 0.8,
                description: "해안선을 따라 시선을 이동하세요"
            ),
            ExercisePhase(
                exerciseType: .saccade,
                pointCount: 20,
                speed: 1.0,
                description: "별들 사이를 빠르게 이동하세요"
            ),
            ExercisePhase(
                exerciseType: .circularTracking,
                pointCount: 30,
                speed: 1.0,
                description: "회오리 패턴을 따라가세요"
            ),
            ExercisePhase(
                exerciseType: .vergence,
                pointCount: 14,
                speed: 0.8,
                description: "가까운 꽃과 먼 산을 번갈아 보세요"
            ),
            ExercisePhase(
                exerciseType: .saccade,
                pointCount: 25,
                speed: 1.5,
                description: "동물을 빠르게 추적하세요"
            )
        ]
    )

    /// 취침 전 릴렉스 (3분)
    static let nightRelax = ExerciseProgram(
        name: "Night Relax",
        nameLocalized: "취침 전 릴렉스",
        duration: 180,
        phases: [
            ExercisePhase(
                exerciseType: .smoothPursuit,
                pointCount: 12,
                speed: 0.4,
                description: "반딧불의 느린 움직임을 따라가세요"
            ),
            ExercisePhase(
                exerciseType: .vergence,
                pointCount: 8,
                speed: 0.3,
                description: "깊게 호흡하며 시선을 천천히 전환하세요"
            )
        ]
    )

    // MARK: - 목 운동 포함 프로그램

    /// 목 스트레칭 (5분) - 목 운동 전용
    static let neckStretch = ExerciseProgram(
        name: "Neck Stretch",
        nameLocalized: "목 스트레칭",
        duration: 300,
        phases: [
            ExercisePhase(
                exerciseType: .neckFlexion,
                pointCount: 8,
                speed: 0.5,
                description: "천천히 고개를 위아래로 끄덕이세요"
            ),
            ExercisePhase(
                exerciseType: .neckRotation,
                pointCount: 8,
                speed: 0.5,
                description: "좌우로 천천히 고개를 돌리세요"
            ),
            ExercisePhase(
                exerciseType: .neckLateralTilt,
                pointCount: 8,
                speed: 0.4,
                description: "귀를 어깨 쪽으로 기울이세요"
            ),
            ExercisePhase(
                exerciseType: .neckCircle,
                pointCount: 12,
                speed: 0.3,
                description: "목을 천천히 원형으로 돌리세요"
            )
        ]
    )

    /// 눈 + 목 콤보 (7분) - 눈과 목 운동 교대
    static let eyeNeckCombo = ExerciseProgram(
        name: "Eye & Neck Combo",
        nameLocalized: "눈+목 콤보 운동",
        duration: 420,
        phases: [
            ExercisePhase(
                exerciseType: .smoothPursuit,
                pointCount: 16,
                speed: 0.8,
                description: "나비를 따라 시선을 이동하세요"
            ),
            ExercisePhase(
                exerciseType: .neckFlexion,
                pointCount: 6,
                speed: 0.5,
                description: "고개를 위아래로 천천히 움직이세요"
            ),
            ExercisePhase(
                exerciseType: .saccade,
                pointCount: 15,
                speed: 1.0,
                description: "별들 사이를 빠르게 이동하세요"
            ),
            ExercisePhase(
                exerciseType: .neckRotation,
                pointCount: 6,
                speed: 0.5,
                description: "좌우로 고개를 돌리세요"
            ),
            ExercisePhase(
                exerciseType: .circularTracking,
                pointCount: 20,
                speed: 0.8,
                description: "새떼의 비행을 따라가세요"
            ),
            ExercisePhase(
                exerciseType: .neckCircle,
                pointCount: 8,
                speed: 0.3,
                description: "목을 천천히 원형으로 돌리며 마무리"
            )
        ]
    )

    /// 오피스 케어 (5분) - 사무실에서 간단히
    static let officeCare = ExerciseProgram(
        name: "Office Care",
        nameLocalized: "오피스 케어",
        duration: 300,
        phases: [
            ExercisePhase(
                exerciseType: .vergence,
                pointCount: 8,
                speed: 0.6,
                description: "가까운 곳과 먼 곳을 번갈아 보세요"
            ),
            ExercisePhase(
                exerciseType: .neckLateralTilt,
                pointCount: 6,
                speed: 0.4,
                description: "목을 좌우로 기울여 스트레칭"
            ),
            ExercisePhase(
                exerciseType: .smoothPursuit,
                pointCount: 12,
                speed: 0.7,
                description: "수평선을 따라 시선을 이동하세요"
            ),
            ExercisePhase(
                exerciseType: .neckFlexion,
                pointCount: 6,
                speed: 0.4,
                description: "고개를 위아래로 천천히 끄덕이세요"
            )
        ]
    )

    /// 모든 기본 프로그램
    static let allPrograms: [ExerciseProgram] = [
        .morningStretch,
        .lunchRefresh,
        .fullCourse,
        .nightRelax,
        .neckStretch,
        .eyeNeckCombo,
        .officeCare
    ]
}
