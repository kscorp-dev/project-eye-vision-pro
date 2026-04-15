# EyeJourney - 상세 기획서

## 1. 앱 개요

| 항목 | 내용 |
|------|------|
| 앱 이름 | EyeJourney |
| 슬로건 | "See the World, Train Your Eyes" |
| 플랫폼 | Apple Vision Pro (visionOS 2.0+) |
| 장르 | 헬스케어 / 게임 |
| 타겟 유저 | Vision Pro 사용자 중 안구 건강에 관심 있는 성인 |
| 언어 | 한국어, 영어 (1차 출시) |

---

## 2. 핵심 컨셉

### 2.1 한 줄 요약
> 아이트래킹으로 세계 풍경 속 경로를 따라가며 자연스럽게 안구운동을 하는 게임

### 2.2 핵심 가치
1. **자연스러움** - 운동이라는 느낌 없이 여행하듯 즐기는 안구운동
2. **효과성** - 안과학 기반 안구운동 패턴을 게임 메커니즘에 녹여냄
3. **몰입감** - Vision Pro의 공간 컴퓨팅으로 실제 여행하는 듯한 경험
4. **지속성** - 게이미피케이션으로 매일 꾸준히 운동하도록 동기부여

---

## 3. 유저 플로우

```
[앱 실행]
    │
    ▼
[홈 화면] ─── 세계 지도에서 목적지 선택
    │
    ├── [일일 추천 루트] ── 오늘의 운동 코스 자동 추천
    │
    ├── [자유 탐험] ── 원하는 지역 직접 선택
    │
    └── [프로필] ── 통계/스탬프/설정
            │
            ▼
[루트 미리보기] ─── 코스 난이도, 예상 시간, 운동 유형 확인
    │
    ▼
[운동 시작] ─── 가이드 포인트 따라 시선 이동 (Look+Pinch)
    │
    ├── 가이드 포인트 바라보기(Look) → 핀치로 확인(Pinch)
    ├── 갈림길 선택 (시선+핀치)
    ├── 이벤트 발생 (동물, 자연현상)
    ├── 목 운동 페이즈 (머리 방향으로 자동 인식)
    └── 보너스 포인트 수집
            │
            ▼
[운동 완료] ─── 결과 요약
    │
    ├── 정확도 / 반응속도 / 운동량
    ├── 스탬프 획득
    ├── 연속 기록 업데이트
    └── 다음 추천 루트 안내
```

---

## 4. 화면 상세 설계

### 4.1 홈 화면 (HomeView)
- **3D 세계 지도** - MapKit 기반, 탐험 가능한 지역 표시
- **일일 미션 카드** - 오늘의 추천 운동 코스
- **연속 기록 배지** - 스트릭 현황
- **빠른 시작 버튼** - 즉시 운동 시작

### 4.2 루트 선택 화면 (RouteSelectView)
- **지역 카드 목록** - 지역별 썸네일, 난이도, 운동 유형 표시
- **난이도 표시** - 초급/중급/고급
- **예상 소요 시간** - 3분/5분/10분 코스
- **잠금/해제 상태** - 이전 루트 완료 시 다음 루트 해제

### 4.3 운동 화면 (ExerciseView)
- **풍경 배경** - MapKit 3D Flyover 또는 360° 파노라마
- **가이드 포인트** - 시선을 유도하는 빛나는 오브젝트
  - 나비, 반딧불, 별, 꽃잎 등 자연 요소
- **진행도 바** - 현재 경로 진행률
- **점수 표시** - 실시간 정확도 피드백
- **갈림길 UI** - 2~3개 방향 선택지 (시선으로 바라보고 핀치로 선택)

### 4.4 결과 화면 (ResultView)
- **운동 요약 카드**
  - 총 운동 시간
  - 시선 이동 거리
  - 정확도 (%)
  - 평균 반응 속도 (ms)
- **스탬프 획득 애니메이션**
- **전후 비교 그래프** (주간/월간)

### 4.5 프로필 화면 (ProfileView)
- **스탬프 컬렉션** - 지역별 스탬프 앨범
- **통계 대시보드** - 일간/주간/월간 운동 기록
- **설정** - 난이도, 속도, 가이드 포인트 스타일

---

## 5. 안구운동 설계

### 5.1 운동 패턴별 게임 메커니즘

#### Smooth Pursuit (부드러운 추적)
- **목적**: 안구 추적 근육 강화
- **구현**: 나비/반딧불이 부드럽게 이동하는 경로를 시선으로 따라감
- **난이도 조절**: 이동 속도, 경로 복잡도

#### Saccade (빠른 시선 이동)
- **목적**: 빠른 시선 전환 능력 향상
- **구현**: 여러 위치에 순서대로 나타나는 별빛을 빠르게 포착
- **난이도 조절**: 포인트 간 거리, 표시 시간

#### Vergence (폭주/개산 운동)
- **목적**: 초점 조절 능력 향상
- **구현**: 가까운 꽃 → 먼 산봉우리를 교대로 주시
- **난이도 조절**: 깊이 차이, 전환 속도

#### Circular Tracking (원형 추적)
- **목적**: 안구 운동 범위 확장
- **구현**: 새떼의 원형 비행 패턴, 회오리 따라가기
- **난이도 조절**: 원의 크기, 회전 속도

### 5.2 운동 프로그램 (7종)

| 프로그램 | 시간 | 유형 | 구성 | 대상 |
|----------|------|------|------|------|
| 모닝 스트레칭 | 3분 | 눈 | 부드러운 추적 + 초점 전환 + 원형 | 기상 직후 |
| 점심 리프레시 | 5분 | 눈 | 빠른 추적 + 원형 + 추적 + 초점 | 오후 피로 해소 |
| 풀 코스 여행 | 10분 | 눈 | 5단계 종합 눈 운동 | 본격 운동 |
| 취침 전 릴렉스 | 3분 | 눈 | 느린 추적 + 깊은 초점 | 취침 전 이완 |
| 목 스트레칭 | 5분 | **목** | 굴곡 → 회전 → 기울이기 → 돌리기 | 목 케어 |
| 눈+목 콤보 | 7분 | **눈+목** | 눈 운동과 목 운동 교대 | 종합 케어 |
| 오피스 케어 | 5분 | **눈+목** | 사무실에서 간단히 | 업무 중 |

---

## 6. 콘텐츠 (지역/루트)

### 6.1 1차 출시 지역 (무료 포함)

| 지역 | 테마 | 주요 운동 | 난이도 |
|------|------|-----------|--------|
| 제주 올레길 | 해안 + 오름 | 수평 추적, 수직 추적 | 초급 |
| 스위스 알프스 | 산악 | 수직 추적, 초점 전환 | 중급 |
| 그리스 산토리니 | 계단 마을 | 빠른 추적, 원형 추적 | 중급 |
| 아이슬란드 오로라 | 야경 | 원형 추적, 부드러운 추적 | 초급 |

### 6.2 시즌 업데이트 (구독/IAP)

| 시즌 | 지역 | 예정 |
|------|------|------|
| 시즌 1 | 일본 교토, 노르웨이 피오르드 | 출시 1개월 후 |
| 시즌 2 | 페루 마추픽추, 이집트 피라미드 | 출시 3개월 후 |
| 시즌 3 | 뉴질랜드, 캐나다 록키 | 출시 6개월 후 |

---

## 7. 데이터 모델

### 7.1 Core Models

```swift
// 사용자 프로필
struct UserProfile {
    var id: UUID
    var nickname: String
    var totalExerciseTime: TimeInterval
    var currentStreak: Int
    var longestStreak: Int
    var stamps: [Stamp]
    var settings: UserSettings
}

// 루트 (여행 코스)
struct Route {
    var id: UUID
    var regionName: String
    var difficulty: Difficulty         // .beginner, .intermediate, .advanced
    var estimatedDuration: TimeInterval
    var exerciseTypes: [ExerciseType]
    var waypoints: [Waypoint]
    var isUnlocked: Bool
}

// 웨이포인트 (경로 포인트)
struct Waypoint {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
    var altitude: Double
    var guideType: GuideType           // .butterfly, .firefly, .star, .petal
    var exercisePattern: ExercisePattern
    var branchOptions: [Branch]?       // 갈림길인 경우
}

// 운동 세션 기록
struct ExerciseSession {
    var id: UUID
    var routeId: UUID
    var startedAt: Date
    var completedAt: Date
    var accuracy: Double               // 0.0 ~ 1.0
    var averageReactionTime: TimeInterval
    var gazeDistance: Double            // 총 시선 이동 거리
    var exerciseBreakdown: [ExerciseTypeResult]
}

// 스탬프
struct Stamp {
    var id: UUID
    var regionName: String
    var iconName: String
    var earnedAt: Date
    var routeId: UUID
}
```

### 7.2 Enums

```swift
enum Difficulty: String, Codable {
    case beginner, intermediate, advanced
}

enum ExerciseType: String, Codable, CaseIterable {
    // 눈 운동 (4종)
    case smoothPursuit    // 부드러운 추적
    case saccade          // 빠른 시선 이동
    case vergence         // 초점 전환
    case circularTracking // 원형 추적
    // 목 운동 (4종)
    case neckFlexion      // 목 앞뒤 굴곡
    case neckRotation     // 목 좌우 회전
    case neckLateralTilt  // 목 좌우 기울이기
    case neckCircle       // 목 돌리기
}

enum GuideType: String, Codable, CaseIterable {
    case butterfly, firefly, star, petal, bird
}
```

---

## 8. 기술 아키텍처

### 8.1 전체 구조 (MVVM)

```
┌─────────────────────────────────────────────┐
│                   Views                      │
│  HomeView · ExerciseView · ProfileView       │
├─────────────────────────────────────────────┤
│                ViewModels                    │
│  HomeVM · ExerciseVM · ProfileVM · MapVM     │
├─────────────────────────────────────────────┤
│                 Services                     │
│  EyeTrackingService · HeadTrackingService    │
│  GameEngine · MapService · MusicService      │
│  SoundService · AchievementService           │
├─────────────────────────────────────────────┤
│               Frameworks                     │
│  ARKit · MapKit · RealityKit · MusicKit      │
│  SwiftData · StoreKit 2 · MediaPlayer        │
└─────────────────────────────────────────────┘
```

### 8.2 핵심 서비스

#### EyeTrackingService
- ARKit의 `ARSession` + `WorldTrackingProvider` 활용
- Device Anchor 기반 디바이스 방향(forward vector) 추적
- 가이드 포인트와의 방향 일치도 기반 정확도 산출
- Look+Pinch 인터랙션: dwell 후 핀치로 명시적 확인
- ※ Apple 프라이버시 정책에 따라 raw eye gaze 좌표는 사용하지 않음

#### MapService
- MapKit의 `MKMapView` (Look Around) 활용
- 3D Flyover 카메라 제어
- 웨이포인트 기반 카메라 경로 생성
- 줌, 틸트, 회전 애니메이션

#### GameEngine
- 가이드 포인트 생성 및 이동 패턴 관리
- 시선 데이터 ↔ 가이드 포인트 매칭
- 점수 계산 및 진행도 관리
- 갈림길 선택 로직 (3초 dwell time)

#### MusicService
- MusicKit + MediaPlayer 기반 배경 음악/팟캐스트 재생
- Apple Music 카탈로그 검색 및 운동용 플레이리스트 자동 재생
- 운동 중 볼륨 자동 조절 (30% ↔ 70%)

---

## 9. 수익 모델

### 9.1 옵션 A: 프리미엄 (유료 앱)
- **가격**: $6.99
- **포함**: 기본 4개 지역 + 모든 운동 프로그램
- **IAP**: 추가 지역 팩 $1.99/팩

### 9.2 옵션 B: 프리미엄 + 구독 (권장)
- **앱 가격**: 무료 (기본 1개 지역 체험)
- **구독**: 월 $2.99 / 연 $19.99
  - 모든 지역 접근
  - 매월 새 루트 추가
  - 상세 통계 분석
  - 맞춤 운동 프로그램

---

## 10. 개발 로드맵

### Phase 1: 프로젝트 세팅 (1주)
- [x] GitHub 레포 생성
- [x] 프로젝트 구조 설정
- [x] 기획 문서 작성
- [x] Xcode 프로젝트 생성 (visionOS 타겟)

### Phase 2: 아이트래킹 프로토타입 (2주)
- [ ] ARKit Eye Tracking 세션 구성
- [ ] 시선 좌표 수집 및 시각화
- [ ] 가이드 포인트 추적 로직
- [ ] 정확도 계산 알고리즘

### Phase 3: MapKit 연동 (2주)
- [ ] MapKit 3D Flyover 표시
- [ ] 카메라 경로 애니메이션
- [ ] 웨이포인트 시스템
- [ ] 지역 데이터 구성

### Phase 4: 게임 엔진 (2주)
- [ ] 가이드 포인트 이동 패턴 (5종)
- [ ] 갈림길 선택 메커니즘
- [ ] 점수/진행도 시스템
- [ ] 운동 프로그램 타이머

### Phase 5: 게이미피케이션 (1주)
- [ ] 스탬프 시스템
- [ ] 스트릭 / 일일 미션
- [ ] 통계 대시보드
- [ ] 결과 화면 애니메이션

### Phase 6: UI/UX 폴리싱 (1주)
- [ ] 공간 UI 디자인 적용
- [ ] 사운드 / 햅틱 피드백
- [ ] 온보딩 튜토리얼
- [ ] 접근성 지원

### Phase 7: 테스트 및 출시 (2주)
- [ ] 유닛 테스트 / UI 테스트
- [ ] TestFlight 베타 배포
- [ ] 피드백 반영
- [ ] App Store 심사 제출

---

## 11. App Store 출시 정보

### 카테고리
- 주 카테고리: Health & Fitness
- 보조 카테고리: Games > Casual

### 키워드
`eye exercise, eye training, vision pro, eye tracking, eye health, 안구운동, 눈운동, 시력훈련`

### 연령 등급
- 4+ (모든 연령)

---

*Last Updated: 2026-04-15*
