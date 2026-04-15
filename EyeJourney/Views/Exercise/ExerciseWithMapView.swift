import SwiftUI
import MapKit

/// 맵 Flyover와 안구운동을 동시에 진행하는 통합 뷰
struct ExerciseWithMapView: View {
    let region: RouteRegion
    @State private var mapService = MapService()
    @State private var gameEngine = GameEngine()
    @State private var eyeTracking = EyeTrackingService()

    @State private var currentWaypointIndex = 0
    @State private var dwellProgress: Float = 0
    @State private var score = 0
    @State private var combo = 0
    @State private var phase: ExercisePhase = .countdown
    @State private var countdown = 3

    @Environment(\.dismiss) private var dismiss

    private var currentWaypoint: RouteWaypoint? {
        guard currentWaypointIndex < region.waypoints.count else { return nil }
        return region.waypoints[currentWaypointIndex]
    }

    var body: some View {
        ZStack {
            // 배경: 3D 맵 Flyover
            mapLayer

            // 오버레이: 게임 UI
            switch phase {
            case .countdown:
                countdownOverlay
            case .active:
                activeOverlay
            case .completed:
                completedOverlay
            }
        }
        .task {
            await startSession()
        }
        .onDisappear {
            eyeTracking.stop()
            mapService.stopFlyover()
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $mapService.mapCameraPosition) {
            if let wp = currentWaypoint {
                Annotation("", coordinate: wp.coordinate) {
                    GuidePointView(
                        position: .zero,
                        progress: dwellProgress,
                        guideType: wp.guideType
                    )
                    .frame(width: 60, height: 60)
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .ignoresSafeArea()
    }

    // MARK: - Countdown

    private var countdownOverlay: some View {
        VStack(spacing: 16) {
            Text(region.nameLocalized)
                .font(.title)
                .fontWeight(.bold)

            if let wp = currentWaypoint {
                Text(wp.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("\(countdown)")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundStyle(.blue.gradient)
                .contentTransition(.numericText())
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Active Exercise

    private var activeOverlay: some View {
        VStack {
            // 상단 HUD
            HStack {
                // 현재 지점 이름
                if let wp = currentWaypoint {
                    Label(wp.name, systemImage: wp.guideType.systemImageName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }

                Spacer()

                // 점수
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("\(score)")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding()

            Spacer()

            // 하단: 가이드 설명 + 진행도
            VStack(spacing: 12) {
                if combo > 1 {
                    Text("COMBO x\(combo)")
                        .font(.headline)
                        .foregroundStyle(.orange.gradient)
                }

                if let wp = currentWaypoint {
                    Text(wp.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Dwell 진행 바
                ProgressView(value: dwellProgress)
                    .tint(dwellProgress >= 1.0 ? .green : .blue)
                    .padding(.horizontal)

                // 전체 진행도
                HStack {
                    Text("\(currentWaypointIndex + 1)/\(region.waypointCount)")
                        .font(.caption2)
                    Spacer()
                    Button("그만하기") { dismiss() }
                        .font(.caption2)
                        .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Completed

    private var completedOverlay: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green.gradient)

            Text("\(region.nameLocalized) 완료!")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 24) {
                resultItem(icon: "star.fill", value: "\(score)", label: "점수", color: .yellow)
                resultItem(icon: "target", value: String(format: "%.0f%%", eyeTracking.accuracy * 100), label: "정확도", color: .blue)
                resultItem(icon: "mappin", value: "\(region.waypointCount)", label: "포인트", color: .orange)
            }

            Button("완료") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    private func resultItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.title3).fontWeight(.bold)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: - Game Logic

    private func startSession() async {
        // 시작 지점으로 카메라 이동
        if let first = region.waypoints.first {
            mapService.moveTo(
                coordinate: first.coordinate,
                distance: first.cameraDistance,
                heading: first.cameraHeading,
                pitch: first.cameraPitch,
                duration: 1.5
            )
        }

        // 카운트다운
        for i in stride(from: 3, through: 1, by: -1) {
            countdown = i
            try? await Task.sleep(for: .seconds(1))
        }

        // 아이트래킹 시작
        await eyeTracking.start()
        phase = .active

        // 운동 루프
        await exerciseLoop()
    }

    private func exerciseLoop() async {
        while currentWaypointIndex < region.waypoints.count {
            guard phase == .active else { break }
            let wp = region.waypoints[currentWaypointIndex]

            // 카메라를 현재 웨이포인트로 이동
            mapService.moveTo(
                coordinate: wp.coordinate,
                distance: wp.cameraDistance,
                heading: wp.cameraHeading,
                pitch: wp.cameraPitch,
                duration: 2.0
            )

            // dwell 추적 루프
            dwellProgress = 0
            while dwellProgress < 1.0 {
                guard phase == .active else { return }
                await eyeTracking.updateGaze()

                // 시선이 맵 중앙 근처에 있으면 dwell 진행
                let isLooking = eyeTracking.isLookingAt(
                    targetPosition: SIMD3<Float>(0, 0, -1.5),
                    threshold: 0.2
                )

                if isLooking {
                    dwellProgress += Float(1.0 / 60.0)
                    if dwellProgress >= 1.0 {
                        eyeTracking.recordHit()
                    }
                } else {
                    dwellProgress = max(0, dwellProgress - Float(0.5 / 60.0))
                    if dwellProgress <= 0 {
                        eyeTracking.recordMiss()
                        combo = 0
                    }
                }

                try? await Task.sleep(for: .milliseconds(16))
            }

            // 웨이포인트 완료
            combo += 1
            let comboMultiplier = min(combo, 5)
            score += 100 * comboMultiplier
            currentWaypointIndex += 1

            // 다음 포인트로 전환 대기
            try? await Task.sleep(for: .seconds(0.5))
        }

        // 운동 완료
        phase = .completed
        eyeTracking.stop()
    }

    enum ExercisePhase {
        case countdown, active, completed
    }
}
