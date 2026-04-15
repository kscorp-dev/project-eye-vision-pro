import ARKit
import RealityKit
import SwiftUI

/// Apple Vision Pro의 아이트래킹 데이터를 수집하고 처리하는 서비스
@Observable
final class EyeTrackingService {
    private var arkitSession = ARKitSession()
    private var worldTracking = WorldTrackingProvider()

    // 현재 시선 데이터
    var gazeDirection: SIMD3<Float> = .zero
    var gazeOrigin: SIMD3<Float> = .zero
    var isTrackingActive = false

    // 시선 통계
    var totalGazeDistance: Float = 0
    private var previousGazePoint: SIMD3<Float>?

    // 정확도 추적
    private var hitCount = 0
    private var totalAttempts = 0

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(hitCount) / Double(totalAttempts)
    }

    /// ARKit 세션 시작 및 Eye Tracking 초기화
    func start() async {
        guard WorldTrackingProvider.isSupported else {
            print("[EyeTracking] WorldTrackingProvider not supported on this device")
            return
        }

        do {
            try await arkitSession.run([worldTracking])
            isTrackingActive = true
            print("[EyeTracking] Session started successfully")
        } catch {
            print("[EyeTracking] Failed to start session: \(error)")
            isTrackingActive = false
        }
    }

    /// 현재 디바이스 앵커로부터 시선 방향 계산
    func updateGaze() async {
        guard isTrackingActive else { return }

        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        guard let anchor = deviceAnchor else { return }

        let transform = anchor.originFromAnchorTransform

        // 디바이스 위치 (시선 원점)
        let newOrigin = SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )

        // 디바이스가 바라보는 방향 (시선 방향)
        let forward = SIMD3<Float>(
            -transform.columns.2.x,
            -transform.columns.2.y,
            -transform.columns.2.z
        )

        gazeOrigin = newOrigin
        gazeDirection = normalize(forward)

        // 시선 이동 거리 누적
        if let prev = previousGazePoint {
            totalGazeDistance += distance(prev, gazeDirection)
        }
        previousGazePoint = gazeDirection
    }

    /// 시선이 특정 위치를 바라보고 있는지 확인
    func isLookingAt(
        targetPosition: SIMD3<Float>,
        threshold: Float = 0.15
    ) -> Bool {
        let toTarget = normalize(targetPosition - gazeOrigin)
        let dotProduct = dot(gazeDirection, toTarget)
        // dot product가 1에 가까울수록 같은 방향
        return dotProduct > (1.0 - threshold)
    }

    /// 시선-타겟 간 거리 (정확도 계산용)
    func gazeDistanceTo(targetPosition: SIMD3<Float>) -> Float {
        let toTarget = targetPosition - gazeOrigin
        let projectionLength = dot(toTarget, gazeDirection)
        let projectedPoint = gazeOrigin + gazeDirection * projectionLength
        return distance(projectedPoint, targetPosition)
    }

    /// 정확도 기록
    func recordHit() {
        hitCount += 1
        totalAttempts += 1
    }

    func recordMiss() {
        totalAttempts += 1
    }

    /// 통계 리셋
    func resetStats() {
        totalGazeDistance = 0
        previousGazePoint = nil
        hitCount = 0
        totalAttempts = 0
    }

    /// 세션 종료
    func stop() {
        arkitSession.stop()
        isTrackingActive = false
        print("[EyeTracking] Session stopped")
    }
}
