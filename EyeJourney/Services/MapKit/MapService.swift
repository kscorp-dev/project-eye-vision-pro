import MapKit
import SwiftUI

/// Apple MapKit 연동 서비스 - 3D Flyover 및 지역 데이터 관리
@Observable
final class MapService {
    var mapCameraPosition: MapCameraPosition
    var isAnimating = false
    var currentHeading: Double = 0
    var flyoverProgress: Float = 0

    private var animationTask: Task<Void, Never>?

    init() {
        let jejuCenter = CLLocationCoordinate2D(latitude: 33.4996, longitude: 126.5312)
        self.mapCameraPosition = .camera(MapCamera(
            centerCoordinate: jejuCenter,
            distance: 5000,
            heading: 0,
            pitch: 45
        ))
    }

    /// 특정 좌표로 카메라 이동
    func moveTo(
        coordinate: CLLocationCoordinate2D,
        distance: Double = 800,
        heading: Double = 0,
        pitch: Double = 60,
        duration: Double = 2.0
    ) {
        withAnimation(.easeInOut(duration: duration)) {
            mapCameraPosition = .camera(MapCamera(
                centerCoordinate: coordinate,
                distance: distance,
                heading: heading,
                pitch: pitch
            ))
            currentHeading = heading
        }
    }

    /// 지역 전체를 미리 보여주는 오버뷰 카메라
    func showRegionOverview(_ region: RouteRegion) {
        moveTo(
            coordinate: region.centerCoordinate,
            distance: region.overviewDistance,
            heading: 0,
            pitch: 45,
            duration: 1.5
        )
    }

    /// 웨이포인트 경로를 따라 3D Flyover 카메라 애니메이션
    func flyAlongRoute(_ region: RouteRegion, speed: FlyoverSpeed = .normal) async {
        animationTask?.cancel()
        isAnimating = true
        flyoverProgress = 0

        let waypoints = region.waypoints
        let total = waypoints.count

        animationTask = Task {
            // 시작점으로 이동
            if let first = waypoints.first {
                moveTo(
                    coordinate: first.coordinate,
                    distance: first.cameraDistance,
                    heading: first.cameraHeading,
                    pitch: first.cameraPitch,
                    duration: 1.5
                )
                try? await Task.sleep(for: .seconds(1.5))
            }

            for (index, wp) in waypoints.enumerated() {
                guard !Task.isCancelled else { break }

                let progress = Float(index + 1) / Float(total)
                flyoverProgress = progress

                moveTo(
                    coordinate: wp.coordinate,
                    distance: wp.cameraDistance,
                    heading: wp.cameraHeading,
                    pitch: wp.cameraPitch,
                    duration: speed.interval
                )

                try? await Task.sleep(for: .seconds(speed.interval))
            }

            isAnimating = false
            flyoverProgress = 1.0
        }
    }

    /// Flyover 중지
    func stopFlyover() {
        animationTask?.cancel()
        isAnimating = false
    }

    // MARK: - Walking Mode (걸어가기 모드)

    /// 보간된 경로를 따라 걸어가듯 부드럽게 이동
    /// 각 스텝을 짧은 간격으로 전환하여 연속적인 이동 느낌 제공
    func walkAlongSteps(
        _ steps: [PathInterpolator.CameraStep],
        preloader: RoutePreloader,
        stepDuration: Double = 0.4,
        onStepReached: @escaping (Int, PathInterpolator.CameraStep) -> Void
    ) async {
        animationTask?.cancel()
        isAnimating = true
        flyoverProgress = 0

        let total = steps.count

        animationTask = Task {
            for (index, step) in steps.enumerated() {
                guard !Task.isCancelled else { break }

                // 다음 구간 프리로드 트리거
                preloader.onStepReached(currentIndex: index, steps: steps)

                // 카메라 이동 (짧은 애니메이션으로 부드럽게)
                withAnimation(.easeInOut(duration: stepDuration)) {
                    mapCameraPosition = .camera(MapCamera(
                        centerCoordinate: step.coordinate,
                        distance: step.distance,
                        heading: step.heading,
                        pitch: step.pitch
                    ))
                    currentHeading = step.heading
                }

                flyoverProgress = Float(index + 1) / Float(total)

                // 콜백: 웨이포인트 도달 알림
                onStepReached(index, step)

                // 스텝 간 대기 (걸어가는 속도)
                try? await Task.sleep(for: .seconds(stepDuration * 0.9))
            }

            isAnimating = false
            flyoverProgress = 1.0
        }
    }

    /// 특정 스텝으로 부드럽게 이동 (사용자가 웨이포인트 완료 후 다음 구간 시작)
    func smoothMoveTo(step: PathInterpolator.CameraStep, duration: Double = 0.6) {
        withAnimation(.easeInOut(duration: duration)) {
            mapCameraPosition = .camera(MapCamera(
                centerCoordinate: step.coordinate,
                distance: step.distance,
                heading: step.heading,
                pitch: step.pitch
            ))
            currentHeading = step.heading
        }
    }

    /// 두 좌표 사이의 방향(heading) 계산
    static func heading(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        let dLon = to.longitude - from.longitude
        let y = sin(dLon * .pi / 180) * cos(to.latitude * .pi / 180)
        let x = cos(from.latitude * .pi / 180) * sin(to.latitude * .pi / 180) -
                sin(from.latitude * .pi / 180) * cos(to.latitude * .pi / 180) * cos(dLon * .pi / 180)
        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: - Flyover Speed

enum FlyoverSpeed: String, CaseIterable {
    case slow = "느리게"
    case normal = "보통"
    case fast = "빠르게"

    var interval: Double {
        switch self {
        case .slow: return 4.0
        case .normal: return 2.5
        case .fast: return 1.5
        }
    }
}
