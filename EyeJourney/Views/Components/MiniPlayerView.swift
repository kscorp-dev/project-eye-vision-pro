import SwiftUI

/// 운동 중 표시되는 미니 음악/팟캐스트 플레이어
struct MiniPlayerView: View {
    @Environment(MusicService.self) private var musicService

    @State private var showMusicPicker = false

    var body: some View {
        if musicService.isPlaying || musicService.currentTrackTitle != nil {
            activePlayer
        } else {
            musicStartButton
        }
    }

    // MARK: - Active Player (재생 중)

    private var activePlayer: some View {
        HStack(spacing: 12) {
            // 트랙 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(musicService.currentTrackTitle ?? "재생 중")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if let artist = musicService.currentArtistName {
                    Text(artist)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: 120, alignment: .leading)

            Spacer()

            // 컨트롤 버튼
            HStack(spacing: 16) {
                Button {
                    musicService.skipToPrevious()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.caption)
                }

                Button {
                    musicService.togglePlayPause()
                } label: {
                    Image(systemName: musicService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.callout)
                }

                Button {
                    musicService.skipToNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Start Button (미재생 시)

    private var musicStartButton: some View {
        Button {
            showMusicPicker = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "music.note")
                    .font(.caption)
                Text("음악 재생")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showMusicPicker) {
            MusicPickerSheet()
        }
    }
}

/// 음악/팟캐스트 선택 시트
struct MusicPickerSheet: View {
    @Environment(MusicService.self) private var musicService
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 권한 상태
                if !musicService.isAuthorized {
                    authorizationView
                } else {
                    contentView
                }
            }
            .padding()
            .navigationTitle("음악 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    private var authorizationView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.house")
                .font(.system(size: 48))
                .foregroundStyle(.blue.gradient)

            Text("Apple Music 접근 권한이 필요합니다")
                .font(.headline)

            Text("운동 중 음악이나 팟캐스트를 들으려면\nApple Music 접근을 허용해주세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("권한 허용하기") {
                Task {
                    await musicService.requestAuthorization()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // 빠른 시작 옵션
            VStack(spacing: 12) {
                quickOption(
                    icon: "play.circle.fill",
                    title: "이어서 재생",
                    subtitle: "마지막으로 듣던 음악을 계속 재생합니다",
                    color: .blue
                ) {
                    musicService.resumePlayback()
                    musicService.setExerciseVolume()
                    dismiss()
                }

                quickOption(
                    icon: "figure.run",
                    title: "운동용 음악",
                    subtitle: "집중할 수 있는 인스트루멘탈 플레이리스트",
                    color: .green
                ) {
                    Task {
                        await musicService.playWorkoutPlaylist()
                        musicService.setExerciseVolume()
                        dismiss()
                    }
                }

                quickOption(
                    icon: "mic.fill",
                    title: "팟캐스트 이어듣기",
                    subtitle: "팟캐스트 앱에서 재생 중인 에피소드 재개",
                    color: .purple
                ) {
                    musicService.playPodcast()
                    musicService.setExerciseVolume()
                    dismiss()
                }
            }

            Divider()

            // 검색
            VStack(alignment: .leading, spacing: 8) {
                Text("음악 검색")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack {
                    TextField("노래, 아티스트 검색...", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    Button("검색") {
                        Task {
                            await musicService.playSearchResult(term: searchText)
                            musicService.setExerciseVolume()
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(searchText.isEmpty)
                }
            }
        }
    }

    private func quickOption(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color.gradient)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
