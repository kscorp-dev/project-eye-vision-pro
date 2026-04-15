import Testing
import CoreLocation
@testable import EyeJourney

@Suite("RouteRegion Tests")
struct RouteRegionTests {

    @Test("4개 지역 존재")
    func allRegionsExist() {
        #expect(RouteRegion.allRegions.count == 4)
    }

    @Test("모든 지역에 웨이포인트 존재")
    func allRegionsHaveWaypoints() {
        for region in RouteRegion.allRegions {
            #expect(!region.waypoints.isEmpty, "\(region.name) has no waypoints")
            #expect(region.waypointCount >= 5, "\(region.name) has too few waypoints")
        }
    }

    @Test("웨이포인트 좌표 유효성")
    func waypointCoordinatesValid() {
        for region in RouteRegion.allRegions {
            for wp in region.waypoints {
                #expect(wp.coordinate.latitude >= -90 && wp.coordinate.latitude <= 90,
                       "Invalid latitude in \(region.name).\(wp.name)")
                #expect(wp.coordinate.longitude >= -180 && wp.coordinate.longitude <= 180,
                       "Invalid longitude in \(region.name).\(wp.name)")
            }
        }
    }

    @Test("카메라 파라미터 유효성")
    func cameraParametersValid() {
        for region in RouteRegion.allRegions {
            for wp in region.waypoints {
                #expect(wp.cameraDistance > 0, "Invalid camera distance")
                #expect(wp.cameraPitch >= 0 && wp.cameraPitch <= 90, "Invalid pitch")
                #expect(wp.cameraHeading >= 0 && wp.cameraHeading < 360, "Invalid heading")
            }
        }
    }

    @Test("제주 올레길 초급 확인")
    func jejuIsBeginner() {
        #expect(RouteRegion.jeju.difficulty == .beginner)
        #expect(RouteRegion.jeju.isUnlocked == true)
    }

    @Test("아이슬란드 초급 해제 상태")
    func icelandUnlocked() {
        #expect(RouteRegion.iceland.difficulty == .beginner)
        #expect(RouteRegion.iceland.isUnlocked == true)
    }

    @Test("스위스/산토리니 중급 잠금 상태")
    func intermediateRoutesLocked() {
        #expect(RouteRegion.swissAlps.difficulty == .intermediate)
        #expect(RouteRegion.swissAlps.isUnlocked == false)
        #expect(RouteRegion.santorini.difficulty == .intermediate)
        #expect(RouteRegion.santorini.isUnlocked == false)
    }

    @Test("각 지역 고유 ID")
    func uniqueRegionIds() {
        let ids = RouteRegion.allRegions.map(\.id)
        #expect(Set(ids).count == ids.count, "Duplicate region IDs found")
    }

    @Test("예상 시간 양수")
    func estimatedMinutesPositive() {
        for region in RouteRegion.allRegions {
            #expect(region.estimatedMinutes > 0)
        }
    }
}
