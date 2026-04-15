import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var appModel
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 상단 인사말 & 스트릭
                    headerSection

                    // 일일 미션 카드
                    dailyMissionCard

                    // 운동 프로그램 선택
                    programSection

                    // 지역 루트 목록
                    routeSection
                }
                .padding()
            }
            .navigationTitle("EyeJourney")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("안녕하세요, 여행자님!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("오늘도 눈 건강을 위한 여행을 떠나볼까요?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 스트릭 배지
            VStack {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundStyle(.orange)
                Text("\(viewModel.currentStreak)일")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var dailyMissionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("오늘의 추천 코스")
                    .fontWeight(.semibold)
                Spacer()
                if viewModel.hasExercisedToday {
                    Label("완료", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }

            HStack(spacing: 16) {
                Image(systemName: "sunrise.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange.gradient)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.recommendedProgram.nameLocalized)
                        .font(.headline)
                    Text("\(Int(viewModel.recommendedProgram.duration / 60))분 코스")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("시작") {
                    viewModel.startExercise()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.hasExercisedToday)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var programSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("운동 프로그램")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ExerciseProgram.allPrograms, id: \.name) { program in
                        ProgramCard(program: program) {
                            viewModel.selectedProgram = program
                            viewModel.startExercise()
                        }
                    }
                }
            }
        }
    }

    private var routeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("세계 여행 루트")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.routes, id: \.id) { route in
                    RouteCard(route: route)
                }
            }
        }
    }
}

// MARK: - Sub Components

struct ProgramCard: View {
    let program: ExerciseProgram
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForProgram(program.name))
                    .font(.title2)
                    .foregroundStyle(.blue.gradient)
                Spacer()
                Text("\(Int(program.duration / 60))분")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(program.nameLocalized)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("\(program.totalWaypoints)개 포인트")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button("시작", action: onStart)
                .buttonStyle(.bordered)
                .font(.caption)
        }
        .padding()
        .frame(width: 160)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .hoverEffect()
    }

    private func iconForProgram(_ name: String) -> String {
        switch name {
        case "Morning Stretch": return "sunrise.fill"
        case "Lunch Refresh": return "sun.max.fill"
        case "Full Course Journey": return "globe.americas.fill"
        case "Night Relax": return "moon.stars.fill"
        default: return "figure.walk"
        }
    }
}

struct RouteCard: View {
    let route: Route

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.gradient.opacity(0.3))
                    .frame(height: 100)

                if route.isUnlocked {
                    Image(systemName: "map.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }

            Text(route.regionNameLocalized)
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack {
                Text(route.difficulty.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(difficultyColor(route.difficulty), in: Capsule())

                Spacer()

                Text("\(Int(route.estimatedDuration / 60))분")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .opacity(route.isUnlocked ? 1.0 : 0.6)
        .hoverEffect()
    }

    private func difficultyColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .beginner: return .green.opacity(0.3)
        case .intermediate: return .orange.opacity(0.3)
        case .advanced: return .red.opacity(0.3)
        }
    }
}
