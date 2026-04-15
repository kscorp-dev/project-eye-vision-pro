import MapKit
import SwiftUI

/// Apple MapKit 연동 서비스 - 3D Flyover 및 지역 데이터 관리
@Observable
final class MapService {
    var currentRegion: MKCoordinateRegion
    var mapCamera: MapCamera
    var isAnimating = false

    init() {
        // 기본 위치: 제주도
        let jejuCenter = CLLocationCoordinate2D(latitude: 33.4996, longitude: 126.5312)
        self.currentRegion = MKCoordinateRegion(
            center: jejuCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        self.mapCamera = MapCamera(
            centerCoordinate: jejuCenter,
            distance: 1000,
            heading: 0,
            pitch: 60
        )
    }

    /// 카메라를 특정 좌표로 이동
    func moveTo(coordinate: CLLocationCoordinate2D, distance: Double = 800, pitch: Double = 60) {
        withAnimation(.easeInOut(duration: 2.0)) {
            mapCamera = MapCamera(
                centerCoordinate: coordinate,
                distance: distance,
                heading: 0,
                pitch: pitch
            )
        }
    }

    /// 웨이포인트 경로를 따라 카메라 애니메이션
    func flyAlongRoute(waypoints: [Waypoint]) async {
        isAnimating = true
        for waypoint in waypoints.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let coord = CLLocationCoordinate2D(
                latitude: waypoint.latitude,
                longitude: waypoint.longitude
            )
            moveTo(coordinate: coord, distance: 500 + waypoint.altitude)
            try? await Task.sleep(for: .seconds(2))
        }
        isAnimating = false
    }
}

// MARK: - 지역 프리셋

extension MapService {
    struct RegionPreset {
        let name: String
        let nameLocalized: String
        let coordinate: CLLocationCoordinate2D
        let altitude: Double
        let thumbnailSystemName: String
    }

    static let presets: [RegionPreset] = [
        RegionPreset(
            name: "Jeju Olle Trail",
            nameLocalized: "제주 올레길",
            coordinate: CLLocationCoordinate2D(latitude: 33.2541, longitude: 126.5700),
            altitude: 200,
            thumbnailSystemName: "water.waves"
        ),
        RegionPreset(
            name: "Swiss Alps",
            nameLocalized: "스위스 알프스",
            coordinate: CLLocationCoordinate2D(latitude: 46.5197, longitude: 7.9624),
            altitude: 3000,
            thumbnailSystemName: "mountain.2.fill"
        ),
        RegionPreset(
            name: "Santorini",
            nameLocalized: "그리스 산토리니",
            coordinate: CLLocationCoordinate2D(latitude: 36.3932, longitude: 25.4615),
            altitude: 300,
            thumbnailSystemName: "building.columns.fill"
        ),
        RegionPreset(
            name: "Iceland Aurora",
            nameLocalized: "아이슬란드 오로라",
            coordinate: CLLocationCoordinate2D(latitude: 64.1466, longitude: -21.9426),
            altitude: 100,
            thumbnailSystemName: "sparkles"
        ),
    ]
}
