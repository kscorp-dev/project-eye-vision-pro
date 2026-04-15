import AVFoundation
import SwiftUI

/// 효과음 관리 — visionOS 호환 (AVAudioPlayer + 시스템 톤)
@Observable
final class SoundService {
    @ObservationIgnored
    @AppStorage("soundEnabled") private var soundEnabled = true

    @ObservationIgnored
    private var players: [SoundEffect: AVAudioPlayer] = [:]

    /// 효과음 재생
    func play(_ effect: SoundEffect) {
        guard soundEnabled else { return }

        // 캐시된 플레이어가 있으면 재사용
        if let player = players[effect] {
            player.currentTime = 0
            player.play()
            return
        }

        // visionOS 호환: 번들 사운드 파일 또는 합성 톤 사용
        guard let url = effect.bundleURL else {
            // 사운드 파일이 없으면 햅틱 대체 (visionOS는 시스템 톤 제한적)
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = effect.volume
            player.prepareToPlay()
            player.play()
            players[effect] = player
        } catch {
            print("[Sound] Failed to play \(effect.rawValue): \(error.localizedDescription)")
        }
    }

    /// 전체 사운드 토글
    func setEnabled(_ enabled: Bool) {
        soundEnabled = enabled
        if !enabled {
            players.values.forEach { $0.stop() }
        }
    }

    var isEnabled: Bool { soundEnabled }
}

enum SoundEffect: String, CaseIterable {
    case waypointReached  // 포인트 도달
    case comboUp          // 콤보 증가
    case exerciseComplete // 운동 완료
    case stampEarned      // 스탬프 획득
    case countdown        // 카운트다운
    case branchSelect     // 분기 선택
    case eventAppear      // 이벤트 발생
    case miss             // 미스

    /// 번들 내 사운드 파일 URL (Resources/Sounds/ 에 배치)
    var bundleURL: URL? {
        Bundle.main.url(forResource: fileName, withExtension: "caf")
        ?? Bundle.main.url(forResource: fileName, withExtension: "wav")
        ?? Bundle.main.url(forResource: fileName, withExtension: "mp3")
    }

    private var fileName: String {
        switch self {
        case .waypointReached: return "waypoint"
        case .comboUp: return "combo"
        case .exerciseComplete: return "complete"
        case .stampEarned: return "stamp"
        case .countdown: return "tick"
        case .branchSelect: return "select"
        case .eventAppear: return "event"
        case .miss: return "miss"
        }
    }

    /// 효과음 볼륨 (0.0~1.0)
    var volume: Float {
        switch self {
        case .exerciseComplete, .stampEarned: return 0.8
        case .comboUp, .eventAppear: return 0.6
        case .waypointReached, .branchSelect: return 0.5
        case .countdown: return 0.4
        case .miss: return 0.3
        }
    }
}
