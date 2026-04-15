import RealityKit
import SwiftUI

/// 시선 추적 대상이 되는 RealityKit 컴포넌트
struct GazeTargetComponent: Component {
    var waypointId: UUID
    var isActive: Bool
    var requiredDwellTime: TimeInterval
    var currentDwellTime: TimeInterval
    var isCompleted: Bool

    init(
        waypointId: UUID,
        requiredDwellTime: TimeInterval = 1.5,
        isActive: Bool = false
    ) {
        self.waypointId = waypointId
        self.isActive = isActive
        self.requiredDwellTime = requiredDwellTime
        self.currentDwellTime = 0
        self.isCompleted = false
    }

    /// dwell 진행률 (0.0 ~ 1.0)
    var dwellProgress: Float {
        Float(min(currentDwellTime / requiredDwellTime, 1.0))
    }
}

/// 시선 타겟의 상태를 업데이트하는 System
struct GazeTargetSystem: System {
    static let query = EntityQuery(where: .has(GazeTargetComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var component = entity.components[GazeTargetComponent.self] else { continue }

            if component.isActive && !component.isCompleted {
                component.currentDwellTime += context.deltaTime
                if component.dwellProgress >= 1.0 {
                    component.isCompleted = true
                }
            } else if !component.isActive {
                // 시선이 벗어나면 dwell 시간 감소
                component.currentDwellTime = max(0, component.currentDwellTime - context.deltaTime * 2)
            }

            entity.components[GazeTargetComponent.self] = component
        }
    }
}
