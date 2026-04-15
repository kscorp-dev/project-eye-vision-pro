import CoreLocation
import MapKit

/// 여행 루트 지역 - 실제 좌표 기반 웨이포인트 데이터
struct RouteRegion: Identifiable {
    let id: String
    let name: String
    let nameLocalized: String
    let description: String
    let iconSystemName: String
    let difficulty: Difficulty
    let estimatedMinutes: Int
    let exerciseTypes: [ExerciseType]
    let centerCoordinate: CLLocationCoordinate2D
    let overviewDistance: Double
    let waypoints: [RouteWaypoint]
    let isUnlocked: Bool

    var waypointCount: Int { waypoints.count }
}

/// 카메라 경로 + 안구운동 정보를 포함하는 웨이포인트
struct RouteWaypoint: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let cameraDistance: Double
    let cameraHeading: Double
    let cameraPitch: Double
    let exerciseType: ExerciseType
    let guideType: GuideType
    let description: String
}

// MARK: - 4개 지역 실제 데이터

extension RouteRegion {

    // =========================================
    // 1. 제주 올레길 (초급)
    // =========================================
    static let jeju = RouteRegion(
        id: "jeju",
        name: "Jeju Olle Trail",
        nameLocalized: "제주 올레길",
        description: "제주도 해안 절경을 따라 걸으며 수평선과 오름을 바라봅니다",
        iconSystemName: "water.waves",
        difficulty: .beginner,
        estimatedMinutes: 3,
        exerciseTypes: [.smoothPursuit, .saccade],
        centerCoordinate: CLLocationCoordinate2D(latitude: 33.2450, longitude: 126.5650),
        overviewDistance: 8000,
        waypoints: [
            RouteWaypoint(
                name: "성산일출봉",
                coordinate: CLLocationCoordinate2D(latitude: 33.4620, longitude: 126.9407),
                cameraDistance: 1200,
                cameraHeading: 220,
                cameraPitch: 55,
                exerciseType: .smoothPursuit,
                guideType: .butterfly,
                description: "일출봉 해안선을 따라 시선을 이동하세요"
            ),
            RouteWaypoint(
                name: "섭지코지",
                coordinate: CLLocationCoordinate2D(latitude: 33.4340, longitude: 126.9275),
                cameraDistance: 800,
                cameraHeading: 180,
                cameraPitch: 50,
                exerciseType: .smoothPursuit,
                guideType: .petal,
                description: "해안 절벽을 따라 나비를 추적하세요"
            ),
            RouteWaypoint(
                name: "표선해비치해변",
                coordinate: CLLocationCoordinate2D(latitude: 33.3270, longitude: 126.8310),
                cameraDistance: 600,
                cameraHeading: 140,
                cameraPitch: 45,
                exerciseType: .smoothPursuit,
                guideType: .butterfly,
                description: "해변의 수평선을 따라 시선을 이동하세요"
            ),
            RouteWaypoint(
                name: "쇠소깍",
                coordinate: CLLocationCoordinate2D(latitude: 33.2520, longitude: 126.6230),
                cameraDistance: 500,
                cameraHeading: 90,
                cameraPitch: 55,
                exerciseType: .saccade,
                guideType: .firefly,
                description: "강과 바다가 만나는 포인트를 빠르게 포착하세요"
            ),
            RouteWaypoint(
                name: "주상절리대",
                coordinate: CLLocationCoordinate2D(latitude: 33.2375, longitude: 126.4110),
                cameraDistance: 700,
                cameraHeading: 300,
                cameraPitch: 60,
                exerciseType: .saccade,
                guideType: .star,
                description: "절리 기둥 사이의 별빛을 포착하세요"
            ),
            RouteWaypoint(
                name: "용머리해안",
                coordinate: CLLocationCoordinate2D(latitude: 33.2350, longitude: 126.3115),
                cameraDistance: 600,
                cameraHeading: 250,
                cameraPitch: 50,
                exerciseType: .smoothPursuit,
                guideType: .bird,
                description: "용의 머리 형상을 따라 시선을 이동하세요"
            ),
        ],
        isUnlocked: true
    )

    // =========================================
    // 2. 스위스 알프스 (중급)
    // =========================================
    static let swissAlps = RouteRegion(
        id: "swiss",
        name: "Swiss Alps",
        nameLocalized: "스위스 알프스",
        description: "만년설 봉우리와 깊은 계곡 사이에서 초점 전환 훈련을 합니다",
        iconSystemName: "mountain.2.fill",
        difficulty: .intermediate,
        estimatedMinutes: 5,
        exerciseTypes: [.vergence, .saccade, .smoothPursuit],
        centerCoordinate: CLLocationCoordinate2D(latitude: 46.5570, longitude: 7.9600),
        overviewDistance: 15000,
        waypoints: [
            RouteWaypoint(
                name: "인터라켄",
                coordinate: CLLocationCoordinate2D(latitude: 46.6863, longitude: 7.8632),
                cameraDistance: 2000,
                cameraHeading: 160,
                cameraPitch: 45,
                exerciseType: .smoothPursuit,
                guideType: .bird,
                description: "두 호수 사이의 마을 경치를 따라가세요"
            ),
            RouteWaypoint(
                name: "그린델발트",
                coordinate: CLLocationCoordinate2D(latitude: 46.6243, longitude: 8.0413),
                cameraDistance: 1500,
                cameraHeading: 200,
                cameraPitch: 55,
                exerciseType: .vergence,
                guideType: .firefly,
                description: "가까운 마을 ↔ 먼 아이거 북벽을 교대로 보세요"
            ),
            RouteWaypoint(
                name: "융프라우요흐",
                coordinate: CLLocationCoordinate2D(latitude: 46.5474, longitude: 7.9856),
                cameraDistance: 2500,
                cameraHeading: 180,
                cameraPitch: 65,
                exerciseType: .vergence,
                guideType: .star,
                description: "눈 앞 빙하 → 멀리 보이는 봉우리로 초점을 전환하세요"
            ),
            RouteWaypoint(
                name: "라우터브루넨 폭포",
                coordinate: CLLocationCoordinate2D(latitude: 46.5937, longitude: 7.9094),
                cameraDistance: 800,
                cameraHeading: 120,
                cameraPitch: 70,
                exerciseType: .saccade,
                guideType: .petal,
                description: "폭포 아래에서 위로 빠르게 시선을 이동하세요"
            ),
            RouteWaypoint(
                name: "뮈렌",
                coordinate: CLLocationCoordinate2D(latitude: 46.5590, longitude: 7.8929),
                cameraDistance: 1200,
                cameraHeading: 240,
                cameraPitch: 50,
                exerciseType: .smoothPursuit,
                guideType: .bird,
                description: "절벽 위 마을에서 독수리의 비행을 따라가세요"
            ),
            RouteWaypoint(
                name: "마터호른 전망",
                coordinate: CLLocationCoordinate2D(latitude: 45.9763, longitude: 7.6586),
                cameraDistance: 3000,
                cameraHeading: 180,
                cameraPitch: 50,
                exerciseType: .vergence,
                guideType: .star,
                description: "마터호른 정상 ↔ 체르마트 마을 초점 전환"
            ),
            RouteWaypoint(
                name: "체르마트",
                coordinate: CLLocationCoordinate2D(latitude: 46.0207, longitude: 7.7491),
                cameraDistance: 1500,
                cameraHeading: 200,
                cameraPitch: 55,
                exerciseType: .saccade,
                guideType: .firefly,
                description: "알프스 봉우리들을 빠르게 찾아보세요"
            ),
        ],
        isUnlocked: false
    )

    // =========================================
    // 3. 그리스 산토리니 (중급)
    // =========================================
    static let santorini = RouteRegion(
        id: "santorini",
        name: "Santorini",
        nameLocalized: "그리스 산토리니",
        description: "파란 지붕과 하얀 계단 마을에서 빠른 시선 이동을 훈련합니다",
        iconSystemName: "building.columns.fill",
        difficulty: .intermediate,
        estimatedMinutes: 5,
        exerciseTypes: [.saccade, .circularTracking, .smoothPursuit],
        centerCoordinate: CLLocationCoordinate2D(latitude: 36.4165, longitude: 25.4325),
        overviewDistance: 10000,
        waypoints: [
            RouteWaypoint(
                name: "피라 마을",
                coordinate: CLLocationCoordinate2D(latitude: 36.4165, longitude: 25.4321),
                cameraDistance: 800,
                cameraHeading: 270,
                cameraPitch: 50,
                exerciseType: .saccade,
                guideType: .star,
                description: "절벽 위 하얀 건물들 사이의 별빛을 포착하세요"
            ),
            RouteWaypoint(
                name: "이아 마을 (블루돔)",
                coordinate: CLLocationCoordinate2D(latitude: 36.4618, longitude: 25.3753),
                cameraDistance: 600,
                cameraHeading: 310,
                cameraPitch: 55,
                exerciseType: .saccade,
                guideType: .butterfly,
                description: "파란 지붕들 사이를 빠르게 이동하세요"
            ),
            RouteWaypoint(
                name: "이아 일몰 포인트",
                coordinate: CLLocationCoordinate2D(latitude: 36.4641, longitude: 25.3720),
                cameraDistance: 1000,
                cameraHeading: 270,
                cameraPitch: 40,
                exerciseType: .smoothPursuit,
                guideType: .petal,
                description: "수평선을 따라 지는 해를 추적하세요"
            ),
            RouteWaypoint(
                name: "칼데라 해안",
                coordinate: CLLocationCoordinate2D(latitude: 36.4030, longitude: 25.4280),
                cameraDistance: 1500,
                cameraHeading: 250,
                cameraPitch: 50,
                exerciseType: .circularTracking,
                guideType: .bird,
                description: "칼데라 위를 원형으로 비행하는 갈매기를 따라가세요"
            ),
            RouteWaypoint(
                name: "카마리 해변",
                coordinate: CLLocationCoordinate2D(latitude: 36.3745, longitude: 25.4700),
                cameraDistance: 700,
                cameraHeading: 90,
                cameraPitch: 45,
                exerciseType: .smoothPursuit,
                guideType: .butterfly,
                description: "검은 모래 해변의 파도를 따라 시선을 이동하세요"
            ),
            RouteWaypoint(
                name: "네아 카메니 화산",
                coordinate: CLLocationCoordinate2D(latitude: 36.4060, longitude: 25.3960),
                cameraDistance: 2000,
                cameraHeading: 180,
                cameraPitch: 55,
                exerciseType: .circularTracking,
                guideType: .firefly,
                description: "화산섬 주위를 회전하며 반딧불을 따라가세요"
            ),
        ],
        isUnlocked: false
    )

    // =========================================
    // 4. 아이슬란드 오로라 (초급)
    // =========================================
    static let iceland = RouteRegion(
        id: "iceland",
        name: "Iceland Aurora",
        nameLocalized: "아이슬란드 오로라",
        description: "오로라와 빙하 속에서 원형 추적과 느린 시선 이동을 훈련합니다",
        iconSystemName: "sparkles",
        difficulty: .beginner,
        estimatedMinutes: 3,
        exerciseTypes: [.circularTracking, .smoothPursuit],
        centerCoordinate: CLLocationCoordinate2D(latitude: 64.0000, longitude: -19.0000),
        overviewDistance: 50000,
        waypoints: [
            RouteWaypoint(
                name: "레이캬비크",
                coordinate: CLLocationCoordinate2D(latitude: 64.1466, longitude: -21.9426),
                cameraDistance: 3000,
                cameraHeading: 0,
                cameraPitch: 45,
                exerciseType: .smoothPursuit,
                guideType: .star,
                description: "항구 해안선을 따라 별빛을 추적하세요"
            ),
            RouteWaypoint(
                name: "씽벨리어 국립공원",
                coordinate: CLLocationCoordinate2D(latitude: 64.2559, longitude: -21.1299),
                cameraDistance: 2000,
                cameraHeading: 90,
                cameraPitch: 50,
                exerciseType: .smoothPursuit,
                guideType: .firefly,
                description: "대서양 중앙 해령의 갈라진 지형을 따라가세요"
            ),
            RouteWaypoint(
                name: "게이시르 간헐천",
                coordinate: CLLocationCoordinate2D(latitude: 64.3104, longitude: -20.3024),
                cameraDistance: 800,
                cameraHeading: 180,
                cameraPitch: 65,
                exerciseType: .circularTracking,
                guideType: .firefly,
                description: "간헐천에서 솟아오르는 수증기를 원형으로 따라가세요"
            ),
            RouteWaypoint(
                name: "굴포스 폭포",
                coordinate: CLLocationCoordinate2D(latitude: 64.3271, longitude: -20.1199),
                cameraDistance: 1000,
                cameraHeading: 120,
                cameraPitch: 60,
                exerciseType: .smoothPursuit,
                guideType: .petal,
                description: "황금빛 폭포의 물줄기를 따라 시선을 이동하세요"
            ),
            RouteWaypoint(
                name: "요쿨살론 빙하 호수",
                coordinate: CLLocationCoordinate2D(latitude: 64.0784, longitude: -16.2306),
                cameraDistance: 1500,
                cameraHeading: 200,
                cameraPitch: 50,
                exerciseType: .circularTracking,
                guideType: .star,
                description: "빙하 호수 위를 떠다니는 빙산 사이를 원형으로 이동하세요"
            ),
            RouteWaypoint(
                name: "다이아몬드 비치",
                coordinate: CLLocationCoordinate2D(latitude: 64.0444, longitude: -16.1778),
                cameraDistance: 600,
                cameraHeading: 150,
                cameraPitch: 40,
                exerciseType: .smoothPursuit,
                guideType: .star,
                description: "검은 모래 위 얼음 조각들 사이로 별빛을 따라가세요"
            ),
        ],
        isUnlocked: true
    )

    /// 모든 지역
    static let allRegions: [RouteRegion] = [jeju, swissAlps, santorini, iceland]
}
