import SwiftUI

/// 앱 설정 화면
struct SettingsView: View {
    @AppStorage("exerciseSpeed") private var exerciseSpeed = 1.0
    @AppStorage("guidePointStyle") private var guidePointStyle = "firefly"
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    @AppStorage("dailyReminder") private var dailyReminder = true
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("language") private var language = "ko"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true

    var body: some View {
        Form {
            // 운동 설정
            Section("운동 설정") {
                HStack {
                    Label("운동 속도", systemImage: "speedometer")
                    Spacer()
                    Picker("", selection: $exerciseSpeed) {
                        Text("느리게").tag(0.7)
                        Text("보통").tag(1.0)
                        Text("빠르게").tag(1.3)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }

                HStack {
                    Label("가이드 포인트", systemImage: "sparkle")
                    Spacer()
                    Picker("", selection: $guidePointStyle) {
                        Text("반딧불").tag("firefly")
                        Text("나비").tag("butterfly")
                        Text("별").tag("star")
                        Text("꽃잎").tag("petal")
                    }
                    .pickerStyle(.menu)
                }
            }

            // 알림 설정
            Section("알림") {
                Toggle(isOn: $dailyReminder) {
                    Label("일일 운동 알림", systemImage: "bell.fill")
                }

                if dailyReminder {
                    HStack {
                        Label("알림 시간", systemImage: "clock.fill")
                        Spacer()
                        Picker("", selection: $reminderHour) {
                            ForEach(6..<23) { hour in
                                Text("\(hour)시").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }

            // 사운드 & 햅틱
            Section("피드백") {
                Toggle(isOn: $soundEnabled) {
                    Label("효과음", systemImage: "speaker.wave.2.fill")
                }
                Toggle(isOn: $hapticEnabled) {
                    Label("햅틱 피드백", systemImage: "hand.tap.fill")
                }
            }

            // 음악 & 팟캐스트
            Section("배경 음악") {
                Toggle(isOn: $backgroundMusicEnabled) {
                    Label("운동 중 음악 재생", systemImage: "music.note")
                }
                if backgroundMusicEnabled {
                    HStack {
                        Label("연동 서비스", systemImage: "music.note.house")
                        Spacer()
                        Text("Apple Music")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 접근성
            Section("접근성") {
                NavigationLink {
                    AccessibilitySettingsView()
                } label: {
                    Label("접근성 설정", systemImage: "accessibility")
                }
            }

            // 기타
            Section("정보") {
                HStack {
                    Label("버전", systemImage: "info.circle")
                    Spacer()
                    Text("0.5")
                        .foregroundStyle(.secondary)
                }

                Button {
                    hasSeenOnboarding = false
                } label: {
                    Label("온보딩 다시 보기", systemImage: "arrow.counterclockwise")
                }

                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("개인정보 처리방침", systemImage: "lock.shield")
                }
            }
        }
        .navigationTitle("설정")
    }
}

/// 접근성 설정
struct AccessibilitySettingsView: View {
    @AppStorage("highContrast") private var highContrast = false
    @AppStorage("largeGuidePoints") private var largeGuidePoints = false
    @AppStorage("reducedMotion") private var reducedMotion = false
    @AppStorage("voiceGuide") private var voiceGuide = false

    var body: some View {
        Form {
            Section("시각") {
                Toggle(isOn: $highContrast) {
                    Label("고대비 모드", systemImage: "circle.lefthalf.filled")
                }
                Toggle(isOn: $largeGuidePoints) {
                    Label("큰 가이드 포인트", systemImage: "plus.magnifyingglass")
                }
            }

            Section("모션") {
                Toggle(isOn: $reducedMotion) {
                    Label("모션 줄이기", systemImage: "figure.stand")
                }
            }

            Section("오디오") {
                Toggle(isOn: $voiceGuide) {
                    Label("음성 가이드", systemImage: "speaker.wave.3.fill")
                }
            }
        }
        .navigationTitle("접근성")
    }
}

/// 개인정보 처리방침
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("개인정보 처리방침")
                    .font(.title2)
                    .fontWeight(.bold)

                Group {
                    sectionText(
                        title: "1. 수집하는 정보",
                        content: "EyeJourney는 안구운동 가이드를 위해 디바이스 방향(Device Anchor) 데이터를 활용합니다. 원시 시선(eye gaze) 좌표는 수집하지 않으며, 모든 데이터는 기기에서만 처리되고 외부 서버로 전송되지 않습니다."
                    )

                    sectionText(
                        title: "2. 정보 사용 목적",
                        content: "디바이스 방향 데이터는 운동 정확도 계산, 진행도 추적, 맞춤 운동 프로그램 제공에만 사용됩니다."
                    )

                    sectionText(
                        title: "3. 데이터 저장",
                        content: "모든 운동 기록과 프로필 데이터는 사용자의 기기에 로컬로 저장되며, iCloud를 통해 사용자의 다른 기기와 동기화될 수 있습니다."
                    )

                    sectionText(
                        title: "4. 제3자 공유",
                        content: "EyeJourney는 사용자의 개인정보를 제3자와 공유하지 않습니다."
                    )

                    sectionText(
                        title: "5. 데이터 삭제",
                        content: "앱을 삭제하면 기기에 저장된 모든 데이터가 삭제됩니다."
                    )
                }

                Text("최종 수정일: 2026년 4월 15일")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .navigationTitle("개인정보 처리방침")
    }

    private func sectionText(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
