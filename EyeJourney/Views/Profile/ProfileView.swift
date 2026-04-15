import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AchievementService.self) private var achievementService
    @Query(sort: \ExerciseSession.startedAt, order: .reverse)
    private var allSessions: [ExerciseSession]
    @State private var profile = UserProfile()

    private var recentSessions: [ExerciseSession] {
        Array(allSessions.prefix(10))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 헤더
                    profileHeader

                    // 퀵 메뉴
                    quickMenu

                    // 통계 카드
                    statsGrid

                    // 스탬프 컬렉션
                    stampCollection

                    // 최근 기록
                    recentHistory
                }
                .padding()
            }
            .navigationTitle("프로필")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .task { loadProfile() }
        }
    }

    private func loadProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? modelContext.fetch(descriptor).first {
            profile = existing
        }
    }

    private var quickMenu: some View {
        HStack(spacing: 12) {
            NavigationLink {
                StatsDashboardView(sessions: recentSessions, profile: profile)
            } label: {
                quickMenuItem(icon: "chart.bar.fill", label: "상세 통계", color: .blue)
            }
            .buttonStyle(.plain)

            NavigationLink {
                AchievementsView(unlockedIds: Set(achievementService.unlockedAchievements.map(\.id)))
            } label: {
                quickMenuItem(icon: "trophy.fill", label: "업적", color: .yellow)
            }
            .buttonStyle(.plain)

            NavigationLink {
                SettingsView()
            } label: {
                quickMenuItem(icon: "gearshape.fill", label: "설정", color: .gray)
            }
            .buttonStyle(.plain)
        }
    }

    private func quickMenuItem(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color.gradient)
            Text(label)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .hoverEffect()
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.nickname)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    Label("\(profile.currentStreak)일 연속", systemImage: "flame.fill")
                        .foregroundStyle(.orange)
                    Label("\(profile.totalSessions)회 운동", systemImage: "figure.walk")
                        .foregroundStyle(.blue)
                }
                .font(.caption)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 통계")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                statCard(
                    title: "총 운동 시간",
                    value: formatDuration(profile.totalExerciseTime),
                    icon: "clock.fill",
                    color: .blue
                )
                statCard(
                    title: "최장 연속",
                    value: "\(profile.longestStreak)일",
                    icon: "flame.fill",
                    color: .orange
                )
                statCard(
                    title: "수집 스탬프",
                    value: "\(profile.stamps.count)개",
                    icon: "stamp.fill",
                    color: .purple
                )
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color.gradient)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Stamp Collection

    private var stampCollection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("여행 스탬프")
                    .font(.headline)
                Spacer()
                Text("\(profile.stamps.count)/\(RouteRegion.allRegions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if profile.stamps.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "stamp")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("아직 수집한 스탬프가 없습니다")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("여행을 완료하면 스탬프를 획득할 수 있어요!")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
                .padding(.vertical, 24)
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80))
                ], spacing: 12) {
                    ForEach(profile.stamps, id: \.id) { stamp in
                        StampCardView(stamp: stamp)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Recent History

    private var recentHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최근 기록")
                .font(.headline)

            if recentSessions.isEmpty {
                HStack {
                    Spacer()
                    Text("아직 운동 기록이 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(recentSessions, id: \.id) { session in
                    sessionRow(session)
                }
            }
        }
    }

    private func sessionRow(_ session: ExerciseSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Text("정확도 \(session.accuracyPercentage)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(session.formattedDuration)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)분"
    }
}
