import SwiftUI
import MapKit

/// 루트 상세 정보 + 3D Flyover 미리보기 + 운동 시작
struct RouteDetailView: View {
    let region: RouteRegion
    @State private var mapService = MapService()
    @State private var showExercise = false
    @State private var selectedSpeed: FlyoverSpeed = .normal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 3D 맵 미리보기
            mapPreview
                .frame(maxHeight: .infinity)

            // 하단 정보 패널
            infoPanel
        }
        .navigationTitle(region.nameLocalized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            mapService.showRegionOverview(region)
        }
        .sheet(isPresented: $showExercise) {
            ExerciseWithMapView(region: region)
        }
    }

    // MARK: - Map Preview

    private var mapPreview: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $mapService.mapCameraPosition) {
                // 웨이포인트 마커
                ForEach(region.waypoints) { wp in
                    Annotation(wp.name, coordinate: wp.coordinate) {
                        VStack(spacing: 2) {
                            Image(systemName: wp.guideType.systemImageName)
                                .font(.caption)
                                .padding(6)
                                .background(
                                    Color.forExerciseType(wp.exerciseType).gradient,
                                    in: Circle()
                                )
                                .foregroundStyle(.white)
                        }
                        .hoverEffect()
                    }
                }

                // 경로 선
                MapPolyline(coordinates: region.waypoints.map(\.coordinate))
                    .stroke(.blue.opacity(0.6), lineWidth: 3)
            }
            .mapStyle(.imagery(elevation: .realistic))

            // Flyover 컨트롤
            VStack(spacing: 8) {
                flyoverButton
                speedSelector
            }
            .padding()
        }
    }

    private var flyoverButton: some View {
        Button {
            if mapService.isAnimating {
                mapService.stopFlyover()
            } else {
                Task { await mapService.flyAlongRoute(region, speed: selectedSpeed) }
            }
        } label: {
            Label(
                mapService.isAnimating ? "중지" : "미리보기 비행",
                systemImage: mapService.isAnimating ? "stop.fill" : "airplane"
            )
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }

    private var speedSelector: some View {
        HStack(spacing: 4) {
            ForEach(FlyoverSpeed.allCases, id: \.self) { speed in
                Button {
                    selectedSpeed = speed
                } label: {
                    Text(speed.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            selectedSpeed == speed
                                ? AnyShapeStyle(.blue.gradient)
                                : AnyShapeStyle(.ultraThinMaterial),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Info Panel

    private var infoPanel: some View {
        VStack(spacing: 16) {
            // 진행 바 (Flyover 중)
            if mapService.isAnimating {
                ProgressView(value: mapService.flyoverProgress)
                    .tint(.blue)
            }

            // 루트 설명
            Text(region.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // 메타데이터
            HStack(spacing: 24) {
                metaItem(
                    icon: "speedometer",
                    label: region.difficulty.displayName,
                    color: difficultyColor
                )
                metaItem(
                    icon: "clock.fill",
                    label: "\(region.estimatedMinutes)분",
                    color: .blue
                )
                metaItem(
                    icon: "mappin.and.ellipse",
                    label: "\(region.waypointCount)개 포인트",
                    color: .orange
                )
            }

            // 운동 유형 태그
            HStack(spacing: 8) {
                ForEach(region.exerciseTypes, id: \.self) { type in
                    Label(type.displayName, systemImage: type.iconName)
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Color.forExerciseType(type).opacity(0.2),
                            in: Capsule()
                        )
                }
            }

            // 웨이포인트 목록
            waypointList

            // 시작 버튼
            Button {
                showExercise = true
            } label: {
                Label("운동 시작", systemImage: "eye.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!region.isUnlocked)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var waypointList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("경로 포인트")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(region.waypoints.enumerated()), id: \.element.id) { index, wp in
                        Button {
                            mapService.moveTo(
                                coordinate: wp.coordinate,
                                distance: wp.cameraDistance,
                                heading: wp.cameraHeading,
                                pitch: wp.cameraPitch
                            )
                        } label: {
                            HStack(spacing: 6) {
                                Text("\(index + 1)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .frame(width: 18, height: 18)
                                    .background(.blue.gradient, in: Circle())
                                    .foregroundStyle(.white)

                                Text(wp.name)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .hoverEffect()
                    }
                }
            }
        }
    }

    private func metaItem(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
    }

    private var difficultyColor: Color {
        switch region.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}
