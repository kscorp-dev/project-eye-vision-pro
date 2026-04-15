import SwiftUI

/// 운동 통계 대시보드
struct StatsDashboardView: View {
    let sessions: [ExerciseSession]
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 주간 활동 차트
                weeklyActivityCard

                // 운동 유형별 통계
                exerciseTypeStats

                // 정확도 추이
                accuracyTrend

                // 상세 기록
                detailedRecords
            }
            .padding()
        }
        .navigationTitle("상세 통계")
    }

    // MARK: - 주간 활동

    private var weeklyActivityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 활동")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date()) ?? Date()
                    let count = sessionsOnDate(date)
                    let isToday = Calendar.current.isDateInToday(date)

                    VStack(spacing: 4) {
                        // 활동 바
                        RoundedRectangle(cornerRadius: 4)
                            .fill(count > 0 ? .blue.gradient : .gray.opacity(0.2))
                            .frame(width: 32, height: CGFloat(max(count * 20, 8)))
                            .frame(height: 60, alignment: .bottom)

                        // 요일
                        Text(dayLabel(date))
                            .font(.caption2)
                            .foregroundStyle(isToday ? .blue : .secondary)
                            .fontWeight(isToday ? .bold : .regular)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            HStack {
                Label("\(weeklySessionCount)회 운동", systemImage: "figure.walk")
                Spacer()
                Label(formatDuration(weeklyTotalTime), systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 운동 유형별

    private var exerciseTypeStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("운동 유형별 성과")
                .font(.headline)

            ForEach(ExerciseType.allCases, id: \.self) { type in
                let stats = statsForType(type)
                HStack(spacing: 12) {
                    Image(systemName: type.iconName)
                        .font(.title3)
                        .foregroundStyle(Color.forExerciseType(type))
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ProgressView(value: stats.averageAccuracy)
                            .tint(Color.forExerciseType(type))
                    }

                    Spacer()

                    Text(String(format: "%.0f%%", stats.averageAccuracy * 100))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.forExerciseType(type))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 정확도 추이

    private var accuracyTrend: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("정확도 추이")
                .font(.headline)

            let recent = Array(sessions.prefix(10).reversed())
            if recent.isEmpty {
                Text("데이터가 부족합니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(recent.enumerated()), id: \.element.id) { _, session in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(accuracyColor(session.accuracy).gradient)
                                .frame(
                                    width: 24,
                                    height: max(CGFloat(session.accuracy) * 80, 4)
                                )

                            Text(String(format: "%.0f", session.accuracy * 100))
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 100, alignment: .bottom)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 상세 기록

    private var detailedRecords: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최근 기록")
                .font(.headline)

            ForEach(sessions.prefix(20), id: \.id) { session in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                        HStack(spacing: 8) {
                            Label(session.accuracyPercentage, systemImage: "target")
                            Label("\(session.totalPoints)점", systemImage: "star.fill")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(session.formattedDuration)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1), in: Capsule())
                }
                .padding(.vertical, 4)

                if session.id != sessions.prefix(20).last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func sessionsOnDate(_ date: Date) -> Int {
        sessions.filter { Calendar.current.isDate($0.startedAt, inSameDayAs: date) }.count
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private var weeklySessionCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.startedAt >= weekAgo }.count
    }

    private var weeklyTotalTime: TimeInterval {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.startedAt >= weekAgo }.reduce(0) { $0 + $1.duration }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        return "\(mins)분"
    }

    private struct TypeStats {
        var averageAccuracy: Double
        var sessionCount: Int
    }

    private func statsForType(_ type: ExerciseType) -> TypeStats {
        let matching = sessions.filter { session in
            session.exerciseResults.contains { $0.type == type }
        }
        let avgAcc = matching.isEmpty ? 0 :
            matching.reduce(0.0) { $0 + $1.accuracy } / Double(matching.count)
        return TypeStats(averageAccuracy: avgAcc, sessionCount: matching.count)
    }

    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 { return .green }
        if accuracy >= 0.7 { return .blue }
        if accuracy >= 0.5 { return .orange }
        return .red
    }
}
