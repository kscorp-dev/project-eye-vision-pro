# EyeJourney - Eye & Neck Exercise App for Apple Vision Pro

> **"See the World, Train Your Eyes"** - 눈으로 떠나는 세계여행, 아이트래킹 기반 안구운동 + 목 운동 게임

[![Platform](https://img.shields.io/badge/Platform-visionOS%202.0+-blue)]()
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()
[![Version](https://img.shields.io/badge/Version-0.3-brightgreen)]()

## Overview

EyeJourney는 Apple Vision Pro의 아이트래킹과 헤드트래킹 기술을 활용하여, 아름다운 세계 풍경 속에서 자연스럽게 **안구운동**과 **목 운동**을 할 수 있는 게임형 헬스케어 앱입니다.

사용자는 시선과 머리 움직임으로 풍경 속 경로를 따라가며, 갈림길에서 방향을 선택하고, 새로운 지역을 탐험합니다. 이 과정에서 상하좌우 안구운동, 초점 전환, 추적 운동, 그리고 목 스트레칭이 자연스럽게 이루어집니다.

## Key Features

### Core Loop
1. 풍경 속에 **경로 포인트**(빛나는 점, 나비, 별 등)가 나타남
2. 유저가 **시선으로 포인트를 순서대로 따라감** (Look + Pinch)
3. 정확하게 따라가면 카메라가 전진하며 **새로운 풍경이 펼쳐짐**
4. **갈림길에서 시선으로 방향을 선택**
5. 선택에 따라 **다른 루트/풍경 언락**
6. 눈 운동 세트 사이에 **목 운동 페이즈가 삽입**되어 복합 운동

### Eye Exercise Types (시선 추적)

| 운동 유형 | 설명 | 게임 요소 |
|-----------|------|-----------|
| **수평 추적** | 수평선을 따라 이동하는 포인트 추적 | 해안선, 지평선 따라가기 |
| **수직 추적** | 위아래로 시선 이동 | 폭포, 절벽 등 수직 지형 탐험 |
| **원형 추적** | 원형 패턴으로 시선 이동 | 회오리, 새떼의 원형 비행 |
| **초점 전환** | 가까운 곳 ↔ 먼 곳 교대 주시 | 가까운 꽃 → 먼 산봉우리 전환 |
| **빠른 추적** | 빠르게 움직이는 대상 추적 | 동물이 빠르게 지나가는 이벤트 |

### Neck Exercise Types (머리 방향 추적) - v0.1 NEW

| 운동 유형 | 설명 | 추적 데이터 |
|-----------|------|-------------|
| **목 앞뒤 굴곡** | 고개를 위아래로 천천히 끄덕이기 | Device Anchor Pitch |
| **목 좌우 회전** | 좌우로 천천히 고개 돌리기 | Device Anchor Yaw |
| **목 좌우 기울이기** | 귀를 어깨 쪽으로 기울이기 | Device Anchor Roll |
| **목 돌리기** | 목을 원형으로 천천히 회전 | Pitch + Yaw 조합 |

> 안전 범위: Pitch ±40°, Yaw ±60°, Roll ±30° — 범위 초과 시 자동 경고

### Exercise Programs (7종)

| 프로그램 | 시간 | 유형 | 설명 |
|----------|------|------|------|
| 모닝 스트레칭 | 3분 | 눈 | 부드러운 추적 → 초점 전환 → 원형 |
| 점심 리프레시 | 5분 | 눈 | 빠른 이동 → 원형 → 추적 → 초점 |
| 풀 코스 여행 | 10분 | 눈 | 5단계 종합 눈 운동 |
| 취침 전 릴렉스 | 3분 | 눈 | 느린 추적 → 초점 전환 |
| **목 스트레칭** | 5분 | **목** | 굴곡 → 회전 → 기울이기 → 돌리기 |
| **눈+목 콤보** | 7분 | **눈+목** | 눈 운동과 목 운동 교대 |
| **오피스 케어** | 5분 | **눈+목** | 사무실에서 간단히 |

### Gamification
- **스탬프 수집** - 각 지역 완료 시 여행 스탬프 획득
- **일일 운동 목표** - 데일리 미션 & 연속 기록 (스트릭)
- **눈 정확도/반응속도 통계** - 아이트래킹 데이터 기반 성과 분석
- **시즌별 루트 추가** - 정기적으로 새로운 지역/테마 업데이트

## Technical Feasibility (기술 구현 가능성)

### 확실히 구현 가능 (90%+)

| 기능 | 기술 | 확신도 |
|------|------|--------|
| 목 운동 추적 | `WorldTrackingProvider` → Device Anchor → Euler Angles | 95% |
| 게임 엔진 (점수/콤보/업적) | 순수 Swift + simd | 95% |
| 데이터 저장 | SwiftData `@Model` | 95% |
| 3D 가이드 배치 | RealityKit `AnchorEntity` + `ModelEntity` | 85% |
| MapKit 카메라 비행 | `MapCamera` position/heading/pitch 제어 | 85% |
| 시선 선택 (Look+Pinch) | visionOS 표준 입력 모델 | 80% |

### 제한적 구현 (수정 필요)

| 기능 | 제약 | 대응 방안 |
|------|------|-----------|
| 눈 좌표 직접 접근 | Apple 프라이버시 정책상 불가 | Look+Pinch 또는 RealityKit Entity dwell 방식 |
| 3D Flyover 풍경 | 주요 도시만 지원 (~200개) | 도시 중심 루트로 변경 (도쿄/런던/파리/로마/뉴욕) |
| 한국 스트리트뷰 | Apple Look Around 한국 미지원 | 카카오맵 Road View (WKWebView) |

### 인터랙션 모델 (수정됨)

```
[눈 운동] 가이드 포인트 바라보기 → HoverEffect 활성화 → 핀치로 확인
[목 운동] 머리 방향 변경 → Device Anchor 각도 추적 → 목표 도달 시 자동 인식
[풍경 탐험] MapKit 카메라 애니메이션 → 시선+핀치로 경로 선택
```

## Tech Stack

| 기술 | 용도 |
|------|------|
| **SwiftUI** | UI 프레임워크 |
| **RealityKit** | 3D 렌더링 및 공간 컴퓨팅 |
| **ARKit (WorldTrackingProvider)** | 머리 방향 추적 (목 운동) + 디바이스 앵커 |
| **ARKit (HoverEffect)** | 시선 기반 시각 피드백 |
| **Apple MapKit** | 3D Flyover 풍경 데이터 |
| **SwiftData** | 로컬 데이터 저장 (진행도, 통계) |
| **StoreKit 2** | 인앱 결제 |

## Architecture

```
EyeJourney/
├── App/                        # 앱 진입점 및 설정
├── Views/
│   ├── Home/                   # 메인 화면 (프로그램 선택, 루트)
│   ├── Exercise/               # 안구운동 + 목운동 게임 화면
│   │   ├── ExerciseView        # 운동 메인 (눈/목 자동 전환)
│   │   ├── NeckExerciseGuide   # 목 운동 방향 가이드 UI
│   │   ├── ExerciseImmersive   # 3D 공간 운동
│   │   └── ExerciseWithMap     # MapKit 연동 운동
│   ├── Map/                    # 풍경 탐험 맵 뷰
│   ├── Profile/                # 프로필, 통계, 스탬프
│   └── Components/             # 공통 UI 컴포넌트
├── ViewModels/                 # 비즈니스 로직
├── Models/                     # 데이터 모델
├── Services/
│   ├── EyeTracking/
│   │   ├── EyeTrackingService  # 디바이스 방향 기반 시선 처리
│   │   ├── HeadTrackingService # 머리 방향 추적 (목 운동)
│   │   └── GazeTargetComponent # RealityKit ECS
│   ├── MapKit/
│   │   ├── MapService          # 카메라 제어 + 걸어가기 모드
│   │   ├── RouteRegion         # 지역 데이터 (4개 지역)
│   │   ├── PathInterpolator    # 경로 보간 (부드러운 걷기)
│   │   └── RoutePreloader      # 맵 타일 사전 로딩
│   ├── GameEngine/
│   │   ├── GameEngine          # 게임 로직 (눈+목 패턴 생성)
│   │   ├── ExerciseProgram     # 7종 운동 프로그램
│   │   ├── AchievementService  # 업적 시스템
│   │   └── DailyMissionService # 일일 미션
│   ├── DataStore/              # SwiftData 저장/조회
│   └── SoundService            # 효과음
├── Resources/                  # 이미지, 3D 에셋, 사운드
└── Extensions/                 # Swift 확장
```

## Requirements

- Apple Vision Pro
- visionOS 2.0+
- Xcode 16.0+
- Swift 6.0+

## Business Model

| 모델 | 내용 |
|------|------|
| **프리미엄 (유료 앱)** | $4.99~$9.99 일회성 구매 |
| **구독형** | 월 $2.99 - 매월 새 루트/풍경 추가 |
| **IAP** | 개별 지역 팩 구매 ($1.99/팩) |

## Version History

### v0.3 - 통합 연결 & 데이터 영속성 (2026-04-15)
- **Home → 운동 네비게이션 수정** — `.sheet` 트리거로 프로그램 기반 운동 즉시 시작
- **SwiftData 연동** — `modelContainer` 앱 레벨 설정, 세션 자동 저장, 프로필 스트릭 업데이트
- **첫 실행 온보딩** — `@AppStorage` 기반 첫 실행 감지, 5페이지 온보딩 플로우
- **DailyMissionService 연결** — HomeView에 오늘의 미션 3종 표시, 완료 체크
- **AchievementService 연결** — 운동 완료 시 업적 조건 자동 확인, 알림 표시
- **SoundService 연결** — 웨이포인트 도달/콤보/운동 완료/이벤트 효과음 재생
- **ProfileView 데이터 연동** — `@Query`로 실제 세션 데이터 표시, MapService.presets 버그 수정
- **EventOverlay/BranchSelection 통합** — 운동 중 보너스 이벤트, 갈림길 선택 UI 활성화
- **앱 생명주기 관리** — `scenePhase` 감시, 백그라운드 진입 시 자동 일시정지

### v0.2 - 걸어가기 모드 & 사전 로딩 (2026-04-15)
- `PathInterpolator` 신규 — 웨이포인트 사이 대원(Great Circle) 경로 보간, ease-in-out 카메라 가감속
- `RoutePreloader` 신규 — MKMapSnapshotter로 맵 타일 사전 캐싱, Look Around 장면 프리로드
- `MapService` 걸어가기 모드 — 보간된 스텝을 0.4초 간격으로 전환, 끊김 없는 이동
- `ExerciseWithMapView` 리팩토링 — loading→countdown→walking→exercise→completed 5단계 플로우
- 로딩 화면: 프리로드 진행률 표시, 이동 중 표시 UI 추가

### v0.1 - 목 운동 기능 추가 (2026-04-15)
- `HeadTrackingService` 신규 — WorldTrackingProvider device anchor에서 pitch/yaw/roll 추출
- 목 운동 4종 추가: 앞뒤 굴곡, 좌우 회전, 좌우 기울이기, 목 돌리기
- 안전 범위 자동 제한 (pitch ±40°, yaw ±60°, roll ±30°) + 경고 UI
- 신규 프로그램 3종: 목 스트레칭(5분), 눈+목 콤보(7분), 오피스 케어(5분)
- `NeckExerciseGuideView` — 목 방향 가이드 UI (타겟/현재 위치 표시)
- `ExerciseViewModel` 리팩토링 — 눈/목 운동 자동 전환 추적 루프
- 기술 구현 가능성 검증 완료 (시선 제약, MapKit 3D 범위, 인터랙션 모델)

### v0.0 - Initial Development (2026-04-15)
- 프로젝트 기획 및 설계
- 아이트래킹 프로토타입 (WorldTrackingProvider)
- MapKit 연동 및 풍경 시스템 (4개 지역, 25개 웨이포인트)
- 게임 엔진: 5종 패턴 생성, 적응형 난이도, 점수/콤보 시스템
- 게이미피케이션: 스탬프, 업적 10종, 일일 미션 6종
- UI/UX: 온보딩, 통계 대시보드, 설정
- 테스트: GameEngine 11개, ExerciseProgram 5개, RouteRegion 9개

## Roadmap

- [x] Phase 1: 프로젝트 세팅 및 기획
- [x] Phase 2: 아이트래킹 프로토타입
- [x] Phase 3: MapKit 연동 및 풍경 시스템
- [x] Phase 4: 게임 엔진 및 운동 로직
- [x] Phase 5: 게이미피케이션 (스탬프, 통계)
- [x] Phase 6: UI/UX 폴리싱
- [x] Phase 7: 테스트 및 출시 준비
- [x] Phase 8: 목 운동 기능 추가 (v0.1)
- [x] Phase 9: 서비스 통합 & 데이터 영속성 (v0.3)
- [ ] Phase 10: 인터랙션 모델 수정 (Look+Pinch)
- [ ] Phase 11: 도시 루트 전환 (3D Flyover 확인 지역)
- [ ] Phase 12: 카카오맵 Road View 연동 (한국)
- [ ] Phase 13: TestFlight 베타
- [ ] Phase 14: App Store 출시

## License

MIT License - See [LICENSE](LICENSE) for details.

---

Built with Apple Vision Pro Eye Tracking & Head Tracking Technology
