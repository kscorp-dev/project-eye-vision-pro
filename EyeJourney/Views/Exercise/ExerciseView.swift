import SwiftUI
import SwiftData

struct ExerciseView: View {
    @State private var viewModel: ExerciseViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(SoundService.self) private var soundService
    @Environment(AchievementService.self) private var achievementService

    @Environment(\.scenePhase) private var scenePhase

    init(program: ExerciseProgram) {
        _viewModel = State(initialValue: ExerciseViewModel(program: program))
    }

    var body: some View {
        ZStack {
            switch viewModel.gameState {
            case .idle:
                countdownView
            case .playing:
                exerciseActiveView
            case .paused:
                pausedView
            case .completed:
                resultView
            case .branching:
                exerciseActiveView
            }

            // 이벤트 오버레이
            if let event = viewModel.activeEvent {
                EventOverlayView(event: event) {
                    soundService.play(.eventAppear)
                    viewModel.dismissEvent()
                }
            }

            // 분기 선택
            if let branch = viewModel.activeBranch {
                BranchSelectionView(branch: branch) { option in
                    soundService.play(.branchSelect)
                    viewModel.selectBranch(option)
                }
            }
        }
        .task {
            await viewModel.startCountdown()
        }
        .onChange(of: viewModel.gameState) { _, newState in
            if newState == .completed {
                soundService.play(.exerciseComplete)
                viewModel.saveSession(modelContext: modelContext)
                checkAchievements()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background, .inactive:
                if viewModel.gameState == .playing {
                    viewModel.pause()
                }
            case .active:
                break // 사용자가 수동으로 재개
            @unknown default:
                break
            }
        }
    }

    private func checkAchievements() {
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let sessionDescriptor = FetchDescriptor<ExerciseSession>()
        guard let profile = try? modelContext.fetch(profileDescriptor).first,
              let sessions = try? modelContext.fetch(sessionDescriptor) else { return }
        achievementService.check(profile: profile, sessions: sessions)
    }

    // MARK: - Countdown

    private var countdownView: some View {
        VStack(spacing: 20) {
            Text("준비하세요")
                .font(.title)
                .fontWeight(.bold)

            Text("\(viewModel.countdown)")
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundStyle(.blue.gradient)
                .contentTransition(.numericText())

            Text(viewModel.currentPhaseDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Active Exercise

    private var exerciseActiveView: some View {
        ZStack {
            // 진행도 바
            VStack {
                exerciseHeader
                Spacer()
                exerciseFooter
            }
            .padding()

            if viewModel.isNeckExercise {
                // 목 운동 가이드
                NeckExerciseGuideView(
                    exerciseType: viewModel.currentExerciseType,
                    targetAngles: viewModel.neckTargetAngles,
                    currentPitch: viewModel.currentHeadPitch,
                    currentYaw: viewModel.currentHeadYaw,
                    currentRoll: viewModel.currentHeadRoll,
                    dwellProgress: viewModel.dwellProgress,
                    safetyWarning: viewModel.neckSafetyWarning
                )
            } else {
                // 눈 운동 가이드 포인트
                GuidePointView(
                    position: viewModel.guidePosition,
                    progress: viewModel.dwellProgress,
                    guideType: viewModel.currentGuideType
                )
            }
        }
    }

    private var exerciseHeader: some View {
        HStack {
            // 현재 운동 유형
            Label(viewModel.currentExerciseType.displayName,
                  systemImage: viewModel.currentExerciseType.iconName)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            // 점수
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("\(viewModel.score)")
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())

            // 일시정지 버튼
            Button {
                viewModel.pause()
            } label: {
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
            }
        }
    }

    private var exerciseFooter: some View {
        VStack(spacing: 8) {
            // 콤보 표시
            if viewModel.combo > 1 {
                Text("COMBO x\(viewModel.combo)")
                    .font(.headline)
                    .foregroundStyle(.orange.gradient)
                    .transition(.scale.combined(with: .opacity))
            }

            // 진행 바
            ProgressView(value: viewModel.progress)
                .tint(.blue)

            HStack {
                Text("\(viewModel.currentWaypointIndex)/\(viewModel.totalWaypoints)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.elapsedTimeFormatted)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Paused

    private var pausedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "pause.circle")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("일시정지")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 16) {
                Button("그만하기") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("계속하기") {
                    viewModel.resume()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Result

    private var resultView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green.gradient)

            Text("운동 완료!")
                .font(.title)
                .fontWeight(.bold)

            // 업적 알림
            if let achievement = achievementService.pendingNotification {
                HStack(spacing: 8) {
                    Image(systemName: achievement.iconName)
                        .foregroundStyle(.yellow)
                    Text(achievement.titleLocalized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.yellow.opacity(0.15), in: Capsule())
                .onAppear { soundService.play(.stampEarned) }
                .onTapGesture { achievementService.dismissNotification() }
            }

            // 결과 요약
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                resultCard(title: "운동 시간", value: viewModel.elapsedTimeFormatted, icon: "clock.fill")
                resultCard(title: "정확도", value: viewModel.accuracyText, icon: "target")
                resultCard(title: "총 점수", value: "\(viewModel.score)", icon: "star.fill")
                resultCard(title: "최고 콤보", value: "x\(viewModel.maxCombo)", icon: "flame.fill")
            }

            Button("완료") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    private func resultCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
