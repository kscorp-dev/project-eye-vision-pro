import SwiftUI
import MapKit

struct MapExplorerView: View {
    @State private var mapService = MapService()
    @State private var selectedPreset: MapService.RegionPreset?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 3D 맵 뷰
                Map(position: .constant(.camera(mapService.mapCamera))) {
                    ForEach(MapService.presets, id: \.name) { preset in
                        Annotation(preset.nameLocalized, coordinate: preset.coordinate) {
                            Image(systemName: preset.thumbnailSystemName)
                                .padding(8)
                                .background(.blue.gradient, in: Circle())
                                .foregroundStyle(.white)
                                .hoverEffect()
                        }
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .frame(maxHeight: .infinity)

                // 하단 지역 선택 바
                regionSelector
            }
            .navigationTitle("세계 탐험")
        }
    }

    private var regionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MapService.presets, id: \.name) { preset in
                    Button {
                        selectedPreset = preset
                        mapService.moveTo(
                            coordinate: preset.coordinate,
                            distance: 800 + preset.altitude
                        )
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: preset.thumbnailSystemName)
                            Text(preset.nameLocalized)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            selectedPreset?.name == preset.name
                                ? AnyShapeStyle(.blue.gradient)
                                : AnyShapeStyle(.ultraThinMaterial),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                    .hoverEffect()
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }
}
