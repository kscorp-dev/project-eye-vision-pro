import SwiftUI
import RealityKit

/// 몰입형 공간에서의 안구운동 뷰 (3D 가이드 포인트)
struct ExerciseImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @State private var eyeTracking = EyeTrackingService()
    @State private var gameEngine = GameEngine()

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

    /// 시선 추적 루프
    private func trackingLoop() async {
        while eyeTracking.isTrackingActive && gameEngine.state == .playing {
            await eyeTracking.updateGaze()

            let isLooking = eyeTracking.isLookingAt(
                targetPosition: gameEngine.activeGuidePosition,
                threshold: 0.12
            )

            if isLooking {
                eyeTracking.recordHit()
            } else {
                eyeTracking.recordMiss()
                gameEngine.onMissed()
            }

            try? await Task.sleep(for: .milliseconds(16)) // ~60fps
        }
    }
}
