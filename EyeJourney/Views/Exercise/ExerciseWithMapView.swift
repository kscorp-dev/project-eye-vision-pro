import SwiftUI
import SwiftData
import MapKit

/// 맵 Flyover와 안구운동을 동시에 진행하는 통합 뷰
/// v0.2: PathInterpolator + RoutePreloader로 걸어가는 듯한 부드러운 이동
struct ExerciseWithMapView: View {
    let region: RouteRegion
    @State private var mapService = MapService()
    @State private var preloader = RoutePreloader()
    @State private var eyeTracking = EyeTrackingService()

    // 보간된 전체 경로
    @State private var walkingSteps: [PathInterpolator.CameraStep] = []
    @State private var currentStepIndex = 0
    @State private var currentWaypointIndex = 0

    @State private var dwellProgress: Float = 0
    @State private var score = 0
    @State private var combo = 0
    @State private var phase: ExercisePhase = .loading
    @State private var countdown = 3
    @State private var isWalkingBetweenPoints = false
    @State private var sessionSaved = false
    @State private var startTime: Date?
    @State private var waitingForPinch = false
    @State private var pinchConfirmed = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SoundService.self) private var soundService
    @Environment(MusicService.self) private var musicService

    private var currentWaypoint: RouteWaypoint? {
        guard currentWaypointIndex < region.waypoints.count else { return nil }
        return region.waypoints[currentWaypointIndex]
    }

    var body: some View {
        ZStack {
            // 배경: 3D 맵
            mapLayer

            // 오버레이
            switch phase {
            case .loading:
                loadingOverlay
            case .countdown:
                countdownOverlay
            case .walking:
                walkingOverlay
            case .exercise:
                exerciseOverlay
            case .completed:
                completedOverlay
            }
        }
        .gesture(
            TapGesture()
                .onEnded {
                    if waitingForPinch {
                        pinchConfirmed = true
                        waitingForPinch = false
                    }
                }
        )
        .task {
            if musicService.isPlaying {
                musicService.setExerciseVolume()
            }
            await prepareAndStart()
        }
        .onDisappear {
            eyeTracking.stop()
            mapService.stopFlyover()
            preloader.clearCache()
            musicService.restoreVolume()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                if phase == .exercise || phase == .walking {
                    eyeTracking.stop()
                    mapService.stopFlyover()
                }
            }
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $mapService.mapCameraPosition) {
            // 운동 중일 때만 가이드 포인트 표시
            if phase == .exercise, let wp = currentWaypoint {
                Annotation("", coordinate: wp.coordinate) {
                    GuidePointView(
                        position: .zero,
                        progress: dwellProgress,
                        guideType: wp.guideType
                    )
                    .frame(width: 60, height: 60)
                }
            }

            // 경로 폴리라인
            MapPolyline(coordinates: region.waypoints.map(\.coordinate))
                .stroke(.blue.opacity(0.4), lineWidth: 3)
        }
        .mapStyle(.imagery(elevation: .realistic))
        .ignoresSafeArea()
    }

    // MARK: - Loading (프리로드)

    private var loadingOverlay: some View {
        VStack(spacing: 20) {
            Text(region.nameLocalized)
                .font(.title)
                .fontWeight(.bold)

            Text("경로를 준비하고 있습니다...")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if case .loading(let progress) = preloader.state {
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .tint(.blue)
                        .frame(width: 200)

                    Text("지도 데이터 로딩 \(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ProgressView()
            }
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
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

    // MARK: - Walking (이동 중)

    private var walkingOverlay: some View {
        VStack {
            // 상단: 이동 안내
            HStack {
                if let wp = currentWaypoint {
                    Label(wp.name, systemImage: "figure.walk")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("\(score)").fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding()

            Spacer()

            // 하단: 이동 중 표시
            VStack(spacing: 8) {
                MiniPlayerView()
                    .padding(.horizontal)

                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("다음 포인트로 이동 중...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: mapService.flyoverProgress)
                    .tint(.cyan)
                    .padding(.horizontal)

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

    // MARK: - Exercise (운동 중 — Look+Pinch)

    private var exerciseOverlay: some View {
        VStack {
            HStack {
                if let wp = currentWaypoint {
                    Label(wp.name, systemImage: wp.guideType.systemImageName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("\(score)").fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding()

            Spacer()

            // 핀치 대기 안내
            if waitingForPinch {
                VStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.green.gradient)
                        .symbolEffect(.pulse, options: .repeating)
                    Text("핀치하여 확인")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

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

                ProgressView(value: dwellProgress)
                    .tint(waitingForPinch ? .green : .blue)
                    .padding(.horizontal)

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

            Button("완료") { dismiss() }
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

    private func prepareAndStart() async {
        // 1) 경로 보간
        walkingSteps = PathInterpolator.interpolate(
            waypoints: region.waypoints,
            stepsPerSegment: 8
        )

        // 2) 시작 지점으로 카메라 이동
        if let first = walkingSteps.first {
            mapService.smoothMoveTo(step: first, duration: 1.0)
        }

        // 3) 초기 구간 프리로드
        phase = .loading
        await preloader.preloadInitialSegment(
            steps: walkingSteps,
            initialCount: min(15, walkingSteps.count)
        )

        // 4) 카운트다운
        phase = .countdown
        for i in stride(from: 3, through: 1, by: -1) {
            countdown = i
            try? await Task.sleep(for: .seconds(1))
        }

        // 5) 시작 시간 기록 & 아이트래킹 시작
        startTime = Date()
        await eyeTracking.start()

        // 6) 운동 루프 시작
        await exerciseLoop()
    }

    private func exerciseLoop() async {
        var stepIndex = 0

        while currentWaypointIndex < region.waypoints.count {
            // --- 걸어가기 구간: 현재 웨이포인트까지의 보간 스텝 이동 ---
            phase = .walking
            isWalkingBetweenPoints = true

            while stepIndex < walkingSteps.count {
                let step = walkingSteps[stepIndex]

                // 프리로드 트리거
                preloader.onStepReached(currentIndex: stepIndex, steps: walkingSteps)

                // 카메라 이동
                mapService.smoothMoveTo(step: step, duration: 0.4)

                // 웨이포인트 도달 → 운동 모드로 전환
                if step.isWaypoint && step.waypointIndex == currentWaypointIndex {
                    stepIndex += 1
                    break
                }

                stepIndex += 1
                try? await Task.sleep(for: .seconds(0.35))
            }

            // --- 운동 구간: Look+Pinch로 웨이포인트 확인 ---
            phase = .exercise
            isWalkingBetweenPoints = false
            dwellProgress = 0
            waitingForPinch = false
            pinchConfirmed = false

            // 1단계: dwell로 시선 확인
            while !pinchConfirmed {
                if waitingForPinch {
                    // 핀치 대기 중 — 시선이 벗어나면 리셋
                    await eyeTracking.updateGaze()
                    let stillLooking = eyeTracking.isLookingAt(
                        targetPosition: SIMD3<Float>(0, 0, -1.5),
                        threshold: 0.25
                    )
                    if !stillLooking {
                        waitingForPinch = false
                        dwellProgress = 0.8
                    }
                    try? await Task.sleep(for: .milliseconds(16))
                    continue
                }

                await eyeTracking.updateGaze()

                let isLooking = eyeTracking.isLookingAt(
                    targetPosition: SIMD3<Float>(0, 0, -1.5),
                    threshold: 0.2
                )

                if isLooking {
                    dwellProgress += Float(1.0 / 60.0)
                    if dwellProgress >= 1.0 {
                        dwellProgress = 1.0
                        waitingForPinch = true
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

            // 웨이포인트 완료 (핀치로 확인됨)
            eyeTracking.recordHit()
            combo += 1
            let comboMultiplier = min(combo, 5)
            score += 100 * comboMultiplier
            currentWaypointIndex += 1

            soundService.play(.waypointReached)
            if combo > 1 { soundService.play(.comboUp) }

            // 짧은 전환 대기
            try? await Task.sleep(for: .seconds(0.3))
        }

        // 모든 웨이포인트 완료
        phase = .completed
        eyeTracking.stop()
        soundService.play(.exerciseComplete)
        saveMapSession()
    }

    private func saveMapSession() {
        guard !sessionSaved else { return }
        sessionSaved = true

        let routeUUID = UUID(uuidString: region.id) ?? UUID()
        let session = ExerciseSession(routeId: routeUUID)
        session.completedAt = Date()
        session.totalPoints = score
        session.accuracy = Double(eyeTracking.accuracy)
        modelContext.insert(session)

        let descriptor = FetchDescriptor<UserProfile>()
        let profile: UserProfile
        if let existing = try? modelContext.fetch(descriptor).first {
            profile = existing
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
        }
        profile.updateStreak()
        profile.totalSessions += 1
        if let start = startTime {
            profile.totalExerciseTime += Date().timeIntervalSince(start)
        }
        try? modelContext.save()
    }

    enum ExercisePhase {
        case loading     // 프리로드 중
        case countdown   // 카운트다운
        case walking     // 다음 포인트로 이동 중 (걸어가기)
        case exercise    // 운동 수행 중 (dwell)
        case completed   // 완료
    }
}
