import Testing
@testable import EyeJourney

@Suite("ExerciseProgram Tests")
struct ExerciseProgramTests {

    @Test("모든 프로그램이 존재")
    func allProgramsExist() {
        #expect(ExerciseProgram.allPrograms.count == 4)
    }

    @Test("모닝 스트레칭 구성")
    func morningStretch() {
        let program = ExerciseProgram.morningStretch
        #expect(program.duration == 180) // 3분
        #expect(!program.phases.isEmpty)
        #expect(program.totalWaypoints > 0)
    }

    @Test("풀 코스 구성")
    func fullCourse() {
        let program = ExerciseProgram.fullCourse
        #expect(program.duration == 600) // 10분
        #expect(program.phases.count >= 4)
        // 모든 운동 유형 포함 확인
        let types = Set(program.phases.map(\.exerciseType))
        #expect(types.count >= 3)
    }

    @Test("프로그램 웨이포인트 수 양수")
    func waypointCounts() {
        for program in ExerciseProgram.allPrograms {
            #expect(program.totalWaypoints > 0, "\(program.name) has no waypoints")
        }
    }

    @Test("페이즈 속도 양수")
    func phaseSpeedsPositive() {
        for program in ExerciseProgram.allPrograms {
            for phase in program.phases {
                #expect(phase.speed > 0, "\(program.name) has invalid speed")
            }
        }
    }
}
