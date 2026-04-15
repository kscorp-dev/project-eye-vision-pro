import SwiftUI
import RealityKit

/// 몰입형 공간에서의 안구운동 뷰 (3D 가이드 포인트, Look+Pinch)
struct ExerciseImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @State private var eyeTracking = EyeTrackingService()
    @State private var gameEngine = GameEngine()
    @State private var dwellProgress: Float = 0
    @State private var waitingForPinch = false

    var body: some View {
        RealityView { content in
            // GazeTarget 시스템 등록
            GazeTargetComponent.registerComponent()
            GazeTargetSystem.registerSystem()

            // 환경 설정
            let anchor = AnchorEntity(.head)
            content.add(anchor)

            // 가이드 포인트 엔티티 생성
            let guideEntity = createGuideEntity()
            anchor.addChild(guideEntity)

        } update: { content in
            // 가이드 포인트 위치 업데이트
            updateGuideEntities(in: content)
        }
        // Look+Pinch: 가이드 포인트 탭(핀치)으로 확인
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    if waitingForPinch {
                        waitingForPinch = false
                        dwellProgress = 0
                        gameEngine.onWaypointReached()
                        eyeTracking.recordHit()
                    }
                }
        )
        .task {
            await eyeTracking.start()
            await trackingLoop()
        }
        .onDisappear {
            eyeTracking.stop()
        }
    }

    /// 가이드 포인트 3D 엔티티 생성
    private func createGuideEntity() -> Entity {
        let entity = Entity()
        entity.name = "GuidePoint"

        let mesh = MeshResource.generateSphere(radius: 0.03)
        let material = SimpleMaterial(
            color: .init(white: 1.0, alpha: 0.9),
            isMetallic: false
        )

        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        modelEntity.components.set(
            GazeTargetComponent(waypointId: UUID(), requiredDwellTime: 1.5, isActive: true)
        )
        modelEntity.components.set(HoverEffectComponent())
        modelEntity.components.set(InputTargetComponent())
        modelEntity.collision = CollisionComponent(
            shapes: [.generateSphere(radius: 0.05)]
        )

        entity.addChild(modelEntity)
        entity.position = gameEngine.activeGuidePosition

        return entity
    }

    /// 가이드 엔티티 위치 업데이트
    private func updateGuideEntities(in content: RealityViewContent) {
        for entity in content.entities {
            if entity.name == "GuidePoint" {
                entity.position = gameEngine.activeGuidePosition
            }
        }
    }

    /// 시선 추적 루프 (Look+Pinch)
    private func trackingLoop() async {
        while eyeTracking.isTrackingActive && gameEngine.state == .playing {
            if waitingForPinch {
                try? await Task.sleep(for: .milliseconds(16))
                continue
            }

            await eyeTracking.updateGaze()

            let isLooking = eyeTracking.isLookingAt(
                targetPosition: gameEngine.activeGuidePosition,
                threshold: 0.12
            )

            if isLooking {
                dwellProgress += Float(1.0 / 60.0 / 1.5)
                if dwellProgress >= 1.0 {
                    dwellProgress = 1.0
                    waitingForPinch = true
                }
            } else {
                dwellProgress = max(0, dwellProgress - Float(2.0 / 60.0))
                if dwellProgress == 0 {
                    eyeTracking.recordMiss()
                    gameEngine.onMissed()
                }
            }

            try? await Task.sleep(for: .milliseconds(16))
        }
    }
}
