import MusicKit
import MediaPlayer
import SwiftUI

/// Apple Music 및 Podcast 재생 서비스 — visionOS 호환
@Observable
final class MusicService {
    // MARK: - State

    private(set) var isPlaying = false
    private(set) var currentTrackTitle: String?
    private(set) var currentArtistName: String?
    private(set) var currentArtworkURL: URL?
    private(set) var authorizationStatus: MusicAuthorization.Status = .notDetermined

    /// 현재 재생 소스 유형
    var activeSource: PlaybackSource = .none

    enum PlaybackSource: String {
        case none
        case appleMusic
        case podcast
    }

    // MARK: - System Music Player

    private let player = MPMusicPlayerController.systemMusicPlayer

    init() {
        observePlaybackState()
    }

    // MARK: - Authorization

    /// MusicKit 권한 요청
    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    // MARK: - Apple Music Playback

    /// 최근 재생 목록에서 재생 재개
    func resumePlayback() {
        player.play()
        activeSource = .appleMusic
        syncNowPlaying()
    }

    /// Apple Music 검색 후 재생
    func playSearchResult(term: String) async {
        guard isAuthorized else { return }

        do {
            var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
            request.limit = 10
            let response = try await request.response()

            guard let song = response.songs.first else { return }
            player.setQueue(with: [song.id.rawValue])
            player.play()
            activeSource = .appleMusic
            syncNowPlaying()
        } catch {
            print("[Music] Search failed: \(error.localizedDescription)")
        }
    }

    /// 추천 플레이리스트 재생 (운동용 음악)
    func playWorkoutPlaylist() async {
        guard isAuthorized else { return }

        do {
            var request = MusicCatalogSearchRequest(term: "workout focus instrumental", types: [Playlist.self])
            request.limit = 5
            let response = try await request.response()

            guard let playlist = response.playlists.first else { return }
            player.setQueue(with: .playlist(persistentID: UInt64(playlist.id.rawValue) ?? 0))
            player.play()
            activeSource = .appleMusic
            syncNowPlaying()
        } catch {
            print("[Music] Playlist failed: \(error.localizedDescription)")
        }
    }

    /// 팟캐스트 재생 (시스템 팟캐스트 앱 연동)
    func playPodcast() {
        // MPMusicPlayerController는 팟캐스트도 재생 가능
        // 사용자가 이미 팟캐스트 앱에서 선택한 에피소드를 재개
        player.play()
        activeSource = .podcast
        syncNowPlaying()
    }

    // MARK: - Controls

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func skipToNext() {
        player.skipToNextItem()
        syncNowPlaying()
    }

    func skipToPrevious() {
        player.skipToPreviousItem()
        syncNowPlaying()
    }

    /// 운동 시작 시 볼륨을 낮춤 (효과음과 겹치지 않도록)
    func setExerciseVolume() {
        player.volume = 0.3
    }

    /// 운동 종료 시 볼륨 복원
    func restoreVolume() {
        player.volume = 0.7
    }

    // MARK: - Now Playing Info

    private func syncNowPlaying() {
        let nowPlaying = player.nowPlayingItem
        currentTrackTitle = nowPlaying?.title
        currentArtistName = nowPlaying?.artist
        if let artwork = nowPlaying?.artwork {
            let image = artwork.image(at: CGSize(width: 60, height: 60))
            // URL은 직접 접근 불가 — artworkURL 대신 title/artist만 표시
            _ = image
        }
        isPlaying = player.playbackState == .playing
    }

    private func observePlaybackState() {
        player.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: player,
            queue: .main
        ) { [weak self] _ in
            self?.syncNowPlaying()
        }
        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player,
            queue: .main
        ) { [weak self] _ in
            self?.syncNowPlaying()
        }
    }

    deinit {
        player.endGeneratingPlaybackNotifications()
    }
}
