import SwiftUI
import MapKit

struct MapExplorerView: View {
    @State private var mapService = MapService()
    @State private var selectedRegion: RouteRegion?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 3D 세계 지도
                mapView
                    .frame(maxHeight: .infinity)

                // 하단 지역 선택 바
                regionSelector
            }
            .navigationTitle("세계 탐험")
            .navigationDestination(isPresented: $showDetail) {
                if let region = selectedRegion {
                    RouteDetailView(region: region)
                }
            }
        }
    }

    // MARK: - Map

    private var mapView: some View {
        Map(position: $mapService.mapCameraPosition) {
            ForEach(RouteRegion.allRegions) { region in
                Annotation(region.nameLocalized, coordinate: region.centerCoordinate) {
                    Button {
                        selectedRegion = region
                        mapService.showRegionOverview(region)
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(region.isUnlocked ? .blue.gradient : .gray.gradient)
                                    .frame(width: 40, height: 40)

                                if region.isUnlocked {
                                    Image(systemName: region.iconSystemName)
                                        .foregroundStyle(.white)
                                        .font(.body)
                                } else {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.white.opacity(0.7))
                                        .font(.caption)
                                }
                            }

                            Text(region.nameLocalized)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                    .hoverEffect()
                }

                // 웨이포인트 경로 표시
                if selectedRegion?.id == region.id {
                    MapPolyline(coordinates: region.waypoints.map(\.coordinate))
                        .stroke(.blue.opacity(0.5), lineWidth: 2)
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
    }

    // MARK: - Region Selector

    private var regionSelector: some View {
        VStack(spacing: 8) {
            // 선택된 지역 정보
            if let region = selectedRegion {
                selectedRegionInfo(region)
            }

            // 지역 목록
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(RouteRegion.allRegions) { region in
                        Button {
                            selectedRegion = region
                            mapService.showRegionOverview(region)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: region.iconSystemName)
                                    .font(.caption)
                                Text(region.nameLocalized)
                                    .font(.subheadline)

                                if !region.isUnlocked {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedRegion?.id == region.id
                                    ? AnyShapeStyle(.blue.gradient)
                                    : AnyShapeStyle(.ultraThinMaterial),
                                in: Capsule()
                            )
                        }
                        .buttonStyle(.plain)
                        .hoverEffect()
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func selectedRegionInfo(_ region: RouteRegion) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(region.nameLocalized)
                    .font(.headline)
                HStack(spacing: 12) {
                    Label(region.difficulty.displayName, systemImage: "speedometer")
                    Label("\(region.estimatedMinutes)분", systemImage: "clock")
                    Label("\(region.waypointCount)개 포인트", systemImage: "mappin")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showDetail = true
            } label: {
                Label("상세보기", systemImage: "arrow.right.circle.fill")
                    .font(.subheadline)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!region.isUnlocked)
        }
        .padding(.horizontal)
    }
}
