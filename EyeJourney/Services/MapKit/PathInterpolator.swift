import CoreLocation
import MapKit

/// 웨이포인트 사이에 중간 지점을 보간하여 "걸어가는 듯한" 부드러운 경로를 생성
struct PathInterpolator {

    /// 보간된 카메라 지점
    struct CameraStep {
        let coordinate: CLLocationCoordinate2D
        let distance: Double
        let heading: Double
        let pitch: Double
        let isWaypoint: Bool    // 원래 웨이포인트인지 보간 지점인지
        let waypointIndex: Int? // 원래 웨이포인트의 인덱스 (보간 지점은 nil)
    }

    /// 두 웨이포인트 사이에 중간 스텝을 삽입하여 부드러운 경로 생성
    /// - Parameters:
    ///   - waypoints: 원래 웨이포인트 배열
    ///   - stepsPerSegment: 웨이포인트 사이에 삽입할 중간 지점 수
    /// - Returns: 보간된 전체 경로 (원래 웨이포인트 + 중간 지점)
    static func interpolate(
        waypoints: [RouteWaypoint],
        stepsPerSegment: Int = 8
    ) -> [CameraStep] {
        guard waypoints.count >= 2 else {
            return waypoints.enumerated().map { i, wp in
                CameraStep(
                    coordinate: wp.coordinate,
                    distance: wp.cameraDistance,
                    heading: wp.cameraHeading,
                    pitch: wp.cameraPitch,
                    isWaypoint: true,
                    waypointIndex: i
                )
            }
        }

        var steps: [CameraStep] = []

        for i in 0..<waypoints.count {
            let current = waypoints[i]

            // 원래 웨이포인트 추가
            steps.append(CameraStep(
                coordinate: current.coordinate,
                distance: current.cameraDistance,
                heading: current.cameraHeading,
                pitch: current.cameraPitch,
                isWaypoint: true,
                waypointIndex: i
            ))

            // 마지막 웨이포인트가 아니면 중간 스텝 삽입
            if i < waypoints.count - 1 {
                let next = waypoints[i + 1]
                let intermediates = generateIntermediateSteps(
                    from: current,
                    to: next,
                    count: stepsPerSegment
                )
                steps.append(contentsOf: intermediates)
            }
        }

        return steps
    }

    /// 두 지점 사이의 중간 스텝 생성 (대원 보간)
    private static func generateIntermediateSteps(
        from: RouteWaypoint,
        to: RouteWaypoint,
        count: Int
    ) -> [CameraStep] {
        (1...count).map { step in
            // 0.0 ~ 1.0 사이의 진행률 (시작/끝 제외)
            let t = Double(step) / Double(count + 1)

            // 좌표 보간 (대원 경로)
            let coord = interpolateCoordinate(
                from: from.coordinate,
                to: to.coordinate,
                fraction: t
            )

            // 카메라 파라미터 보간 (ease-in-out 커브)
            let eased = easeInOut(t)
            let distance = lerp(from.cameraDistance, to.cameraDistance, t: eased)
            let pitch = lerp(from.cameraPitch, to.cameraPitch, t: eased)

            // 헤딩은 다음 지점을 향하도록 계산
            let heading = interpolateHeading(
                from: from.cameraHeading,
                to: to.cameraHeading,
                fraction: eased
            )

            return CameraStep(
                coordinate: coord,
                distance: distance,
                heading: heading,
                pitch: pitch,
                isWaypoint: false,
                waypointIndex: nil
            )
        }
    }

    /// 대원(Great Circle) 경로 위의 좌표 보간
    private static func interpolateCoordinate(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        fraction: Double
    ) -> CLLocationCoordinate2D {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        // 두 지점 사이의 각거리
        let d = acos(
            sin(lat1) * sin(lat2) +
            cos(lat1) * cos(lat2) * cos(lon2 - lon1)
        )

        // 거리가 매우 작으면 선형 보간
        guard d > 1e-10 else {
            return CLLocationCoordinate2D(
                latitude: from.latitude + (to.latitude - from.latitude) * fraction,
                longitude: from.longitude + (to.longitude - from.longitude) * fraction
            )
        }

        let a = sin((1 - fraction) * d) / sin(d)
        let b = sin(fraction * d) / sin(d)

        let x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2)
        let y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2)
        let z = a * sin(lat1) + b * sin(lat2)

        let lat = atan2(z, sqrt(x * x + y * y)) * 180 / .pi
        let lon = atan2(y, x) * 180 / .pi

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    /// 헤딩 보간 (최단 각도 경로)
    private static func interpolateHeading(
        from: Double,
        to: Double,
        fraction: Double
    ) -> Double {
        var diff = to - from
        // 최단 경로로 회전 (예: 350° → 10° = +20°, -340°가 아님)
        if diff > 180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        let result = from + diff * fraction
        return (result + 360).truncatingRemainder(dividingBy: 360)
    }

    /// 선형 보간
    private static func lerp(_ a: Double, _ b: Double, t: Double) -> Double {
        a + (b - a) * t
    }

    /// Ease-in-out 커브 (부드러운 가감속)
    private static func easeInOut(_ t: Double) -> Double {
        t < 0.5
            ? 2 * t * t
            : 1 - pow(-2 * t + 2, 2) / 2
    }
}
