import Testing
import simd
@testable import EyeJourney

@Suite("Neck Exercise Tests")
struct NeckExerciseTests {

    // MARK: - ExerciseType 분류

    @Test("목 운동 타입 식별")
    func neckExerciseTypeIdentification() {
        #expect(ExerciseType.neckFlexion.isNeckExercise == true)
        #expect(ExerciseType.neckRotation.isNeckExercise == true)
        #expect(ExerciseType.neckLateralTilt.isNeckExercise == true)
        #expect(ExerciseType.neckCircle.isNeckExercise == true)
    }

    @Test("눈 운동 타입 식별")
    func eyeExerciseTypeIdentification() {
        #expect(ExerciseType.smoothPursuit.isEyeExercise == true)
        #expect(ExerciseType.saccade.isEyeExercise == true)
        #expect(ExerciseType.vergence.isEyeExercise == true)
        #expect(ExerciseType.circularTracking.isEyeExercise == true)
    }

    @Test("목 운동 displayName 존재")
    func neckExerciseDisplayNames() {
        #expect(!ExerciseType.neckFlexion.displayName.isEmpty)
        #expect(!ExerciseType.neckRotation.displayName.isEmpty)
        #expect(!ExerciseType.neckLateralTilt.displayName.isEmpty)
        #expect(!ExerciseType.neckCircle.displayName.isEmpty)
    }

    @Test("목 운동 iconName 존재")
    func neckExerciseIcons() {
        #expect(!ExerciseType.neckFlexion.iconName.isEmpty)
        #expect(!ExerciseType.neckRotation.iconName.isEmpty)
        #expect(!ExerciseType.neckLateralTilt.iconName.isEmpty)
        #expect(!ExerciseType.neckCircle.iconName.isEmpty)
    }

    // MARK: - 목 운동 패턴 생성

    @Test("Neck Flexion 패턴 생성")
    func neckFlexionPattern() {
        let points = GameEngine.generateNeckFlexionPattern(pointCount: 10)
        #expect(points.count == 10)

        // pitch(y)만 변화, yaw(x)와 roll(z)은 0
        for point in points {
            #expect(point.x == 0, "yaw는 0이어야 함")
            #expect(point.z == 0, "roll은 0이어야 함")
        }

        // pitch 범위 확인 (±25° = ±0.436 rad)
        let maxPitch = points.map { abs($0.y) }.max() ?? 0
        #expect(maxPitch <= 26 * .pi / 180, "pitch가 안전 범위 초과")
        #expect(maxPitch > 0, "pitch 변화가 있어야 함")
    }

    @Test("Neck Rotation 패턴 생성")
    func neckRotationPattern() {
        let points = GameEngine.generateNeckRotationPattern(pointCount: 10)
        #expect(points.count == 10)

        // yaw(x)만 변화
        for point in points {
            #expect(point.y == 0, "pitch는 0이어야 함")
            #expect(point.z == 0, "roll은 0이어야 함")
        }

        let maxYaw = points.map { abs($0.x) }.max() ?? 0
        #expect(maxYaw <= 41 * .pi / 180, "yaw가 안전 범위 초과")
        #expect(maxYaw > 0, "yaw 변화가 있어야 함")
    }

    @Test("Neck Lateral Tilt 패턴 생성")
    func neckLateralTiltPattern() {
        let points = GameEngine.generateNeckLateralTiltPattern(pointCount: 10)
        #expect(points.count == 10)

        // roll(z)만 변화
        for point in points {
            #expect(point.x == 0, "yaw는 0이어야 함")
            #expect(point.y == 0, "pitch는 0이어야 함")
        }

        let maxRoll = points.map { abs($0.z) }.max() ?? 0
        #expect(maxRoll <= 21 * .pi / 180, "roll이 안전 범위 초과")
    }

    @Test("Neck Circle 패턴 생성")
    func neckCirclePattern() {
        let points = GameEngine.generateNeckCirclePattern(pointCount: 16)
        #expect(points.count == 16)

        // yaw(x)와 pitch(y) 모두 변화, roll(z)은 0
        for point in points {
            #expect(point.z == 0, "roll은 0이어야 함")
        }

        // 원형 패턴이므로 다양한 각도에 포인트 분포
        let hasPositiveYaw = points.contains { $0.x > 0.05 }
        let hasNegativeYaw = points.contains { $0.x < -0.05 }
        let hasPositivePitch = points.contains { $0.y > 0.05 }
        let hasNegativePitch = points.contains { $0.y < -0.05 }
        #expect(hasPositiveYaw, "양의 yaw 포인트 필요")
        #expect(hasNegativeYaw, "음의 yaw 포인트 필요")
        #expect(hasPositivePitch, "양의 pitch 포인트 필요")
        #expect(hasNegativePitch, "음의 pitch 포인트 필요")
    }

    @Test("패턴 최소 포인트 수")
    func minimumPointCount() {
        #expect(GameEngine.generateNeckFlexionPattern(pointCount: 2).count == 2)
        #expect(GameEngine.generateNeckRotationPattern(pointCount: 2).count == 2)
        #expect(GameEngine.generateNeckLateralTiltPattern(pointCount: 2).count == 2)
        #expect(GameEngine.generateNeckCirclePattern(pointCount: 4).count == 4)
    }

    // MARK: - 안전 범위

    @Test("안전 범위 상수 확인")
    func safetyRangeConstants() {
        // 의학적으로 안전한 범위 내인지 확인
        #expect(HeadTrackingService.maxPitchRange <= 45 * .pi / 180, "pitch 최대 45° 이하")
        #expect(HeadTrackingService.maxYawRange <= 70 * .pi / 180, "yaw 최대 70° 이하")
        #expect(HeadTrackingService.maxRollRange <= 35 * .pi / 180, "roll 최대 35° 이하")
    }

    // MARK: - 프로그램

    @Test("목 스트레칭 프로그램 구성")
    func neckStretchProgram() {
        let program = ExerciseProgram.neckStretch
        #expect(program.duration == 300) // 5분
        #expect(program.phases.count == 4)

        // 모든 페이즈가 목 운동인지 확인
        for phase in program.phases {
            #expect(phase.exerciseType.isNeckExercise, "\(phase.exerciseType) is not neck exercise")
        }
    }

    @Test("눈+목 콤보 프로그램 구성")
    func eyeNeckComboProgram() {
        let program = ExerciseProgram.eyeNeckCombo
        #expect(program.duration == 420) // 7분
        #expect(program.phases.count == 6)

        // 눈 운동과 목 운동이 모두 포함되어야 함
        let hasEye = program.phases.contains { $0.exerciseType.isEyeExercise }
        let hasNeck = program.phases.contains { $0.exerciseType.isNeckExercise }
        #expect(hasEye, "눈 운동 포함 필요")
        #expect(hasNeck, "목 운동 포함 필요")
    }

    @Test("오피스 케어 프로그램 구성")
    func officeCareProgram() {
        let program = ExerciseProgram.officeCare
        #expect(program.duration == 300) // 5분

        let hasEye = program.phases.contains { $0.exerciseType.isEyeExercise }
        let hasNeck = program.phases.contains { $0.exerciseType.isNeckExercise }
        #expect(hasEye, "눈 운동 포함 필요")
        #expect(hasNeck, "목 운동 포함 필요")
    }

    @Test("전체 프로그램 수 (목 운동 포함)")
    func totalProgramCount() {
        #expect(ExerciseProgram.allPrograms.count == 7)
    }

    @Test("목 운동 포함 프로그램 속도 안전")
    func neckExerciseSpeedSafety() {
        for program in ExerciseProgram.allPrograms {
            for phase in program.phases where phase.exerciseType.isNeckExercise {
                #expect(phase.speed <= 0.8, "\(program.name)의 목 운동 속도가 너무 빠름: \(phase.speed)")
            }
        }
    }
}
