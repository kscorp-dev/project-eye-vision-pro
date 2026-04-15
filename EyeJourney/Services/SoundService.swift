import AVFoundation
import SwiftUI

/// 효과음 및 사운드 관리
@Observable
final class SoundService {
    private var players: [SoundEffect: AVAudioPlayer] = [:]

    @AppStorage("soundEnabled") private var soundEnabled = true

    /// 시스템 사운드로 효과음 재생
    func play(_ effect: SoundEffect) {
        guard soundEnabled else { return }

        // visionOS에서는 시스템 사운드 활용
        switch effect {
        case .waypointReached:
            playSystemSound(1057) // Tink
        case .comboUp:
            playSystemSound(1075) // Fanfare
        case .exerciseComplete:
            playSystemSound(1025) // Tada
        case .stampEarned:
            playSystemSound(1026) // Stamp
        case .countdown:
            playSystemSound(1113) // Tick
        case .branchSelect:
            playSystemSound(1104) // Click
        case .eventAppear:
            playSystemSound(1117) // Magic
        case .miss:
            playSystemSound(1053) // Pop
        }
    }

    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
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
}
