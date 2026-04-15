# EyeJourney - Eye Exercise App for Apple Vision Pro

> **"See the World, Train Your Eyes"** - 눈으로 떠나는 세계여행, 아이트래킹 기반 안구운동 게임

[![Platform](https://img.shields.io/badge/Platform-visionOS%202.0+-blue)]()
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()

## Overview

EyeJourney는 Apple Vision Pro의 아이트래킹 기술을 활용하여, 아름다운 세계 풍경 속에서 자연스럽게 안구운동을 할 수 있는 게임형 헬스케어 앱입니다.

사용자는 시선만으로 풍경 속 경로를 따라가며, 갈림길에서 방향을 선택하고, 새로운 지역을 탐험합니다. 이 과정에서 상하좌우 안구운동, 초점 전환, 추적 운동이 자연스럽게 이루어집니다.

## Key Features

### Core Loop
1. 풍경 속에 **경로 포인트**(빛나는 점, 나비, 별 등)가 나타남
2. 유저가 **시선으로 포인트를 순서대로 따라감**
3. 정확하게 따라가면 카메라가 전진하며 **새로운 풍경이 펼쳐짐**
4. **갈림길에서 시선으로 방향을 선택**
5. 선택에 따라 **다른 루트/풍경 언락**

### Eye Exercise Types

| 운동 유형 | 설명 | 게임 요소 |
|-----------|------|-----------|
| **수평 추적** | 수평선을 따라 이동하는 포인트 추적 | 해안선, 지평선 따라가기 |
| **수직 추적** | 위아래로 시선 이동 | 폭포, 절벽 등 수직 지형 탐험 |
| **원형 추적** | 원형 패턴으로 시선 이동 | 회오리, 새떼의 원형 비행 |
| **초점 전환** | 가까운 곳 ↔ 먼 곳 교대 주시 | 가까운 꽃 → 먼 산봉우리 전환 |
| **빠른 추적** | 빠르게 움직이는 대상 추적 | 동물이 빠르게 지나가는 이벤트 |

### Gamification
- **스탬프 수집** - 각 지역 완료 시 여행 스탬프 획득
- **일일 운동 목표** - 데일리 미션 & 연속 기록 (스트릭)
- **눈 정확도/반응속도 통계** - 아이트래킹 데이터 기반 성과 분석
- **시즌별 루트 추가** - 정기적으로 새로운 지역/테마 업데이트

## Tech Stack

| 기술 | 용도 |
|------|------|
| **SwiftUI** | UI 프레임워크 |
| **RealityKit** | 3D 렌더링 및 공간 컴퓨팅 |
| **ARKit (Eye Tracking API)** | 시선 추적 데이터 수집 |
| **Apple MapKit** | 3D Flyover 풍경 데이터 |
| **SwiftData** | 로컬 데이터 저장 (진행도, 통계) |
| **StoreKit 2** | 인앱 결제 |

## Project Structure

```
EyeJourney/
├── App/                    # 앱 진입점 및 설정
├── Views/
│   ├── Home/               # 메인 화면 (지도, 루트 선택)
│   ├── Exercise/           # 안구운동 게임 화면
│   ├── Map/                # 풍경 탐험 맵 뷰
│   ├── Profile/            # 프로필, 통계, 스탬프
│   └── Components/         # 공통 UI 컴포넌트
├── ViewModels/             # 비즈니스 로직
├── Models/                 # 데이터 모델
├── Services/
│   ├── EyeTracking/        # 아이트래킹 처리
│   ├── MapKit/             # Apple MapKit 연동
│   ├── GameEngine/         # 게임 로직 엔진
│   └── DataStore/          # 데이터 저장/조회
├── Resources/
│   ├── Assets/             # 이미지, 3D 에셋
│   ├── Sounds/             # 효과음, BGM
│   └── Animations/         # 애니메이션 리소스
└── Extensions/             # Swift 확장
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

## Roadmap

- [x] Phase 1: 프로젝트 세팅 및 기획
- [ ] Phase 2: 아이트래킹 프로토타입
- [ ] Phase 3: MapKit 연동 및 풍경 시스템
- [ ] Phase 4: 게임 엔진 및 운동 로직
- [ ] Phase 5: 게이미피케이션 (스탬프, 통계)
- [ ] Phase 6: UI/UX 폴리싱
- [ ] Phase 7: TestFlight 베타
- [ ] Phase 8: App Store 출시

## License

MIT License - See [LICENSE](LICENSE) for details.

---

Built with Apple Vision Pro Eye Tracking Technology
