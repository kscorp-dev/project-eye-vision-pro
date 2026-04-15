import ARKit
import RealityKit
import SwiftUI
import simd

/// Apple Vision Pro의 디바이스 앵커로부터 머리 방향(pitch/yaw/roll)을 추출하여
/// 목 운동 추적을 제공하는 서비스
@Observable
final class HeadTrackingService {
    private var arkitSession = ARKitSession()
    private var worldTracking = WorldTrackingProvider()

    // 현재 머리 방향 (라디안)
    var pitch: Float = 0    // 위아래 고개 끄덕임 (양수 = 위)
    var yaw: Float = 0      // 좌우 회전 (양수 = 왼쪽)
    var roll: Float = 0     // 좌우 기울임 (양수 = 오른쪽 기울임)

    // 기준 방향 (캘리브레이션)
    private var basePitch: Float = 0
    private var baseYaw: Float = 0
    private var baseRoll: Float = 0
    private var isCalibrated = false

    // 상태
    var isTrackingActive = false

    // 통계
    private var hitCount = 0
    private var totalAttempts = 0
    var totalMovementDistance: Float = 0
    private var previousAngles: SIMD3<Float>?

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(hitCount) / Double(totalAttempts)
    }

    // 안전 범위 (라디안) - 과도한 목 운동 방지
    static let maxPitchRange: Float = 40 * .pi / 180  // ±40°
    static let maxYawRange: Float = 60 * .pi / 180     // ±60°
    static let maxRollRange: Float = 30 * .pi / 180    // ±30°

    /// ARKit 세션 시작
    func start() async {
        guard WorldTrackingProvider.isSupported else {
            print("[HeadTracking] WorldTrackingProvider not supported")
            return
        }

        do {
            try await arkitSession.run([worldTracking])
            isTrackingActive = true
            isCalibrated = false
            print("[HeadTracking] Session started")
        } catch {
            print("[HeadTracking] Failed to start: \(error)")
            isTrackingActive = false
        }
    }

    /// 현재 머리 방향 업데이트
    func update() async {
        guard isTrackingActive else { return }

        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        guard let anchor = deviceAnchor else { return }

        let transform = anchor.originFromAnchorTransform
        let angles = extractEulerAngles(from: transform)

        // 첫 프레임에서 기준 방향 설정
        if !isCalibrated {
            calibrate(with: angles)
        }

        // 기준 대비 상대 각도
        pitch = angles.x - basePitch
        yaw = angles.y - baseYaw
        roll = angles.z - baseRoll

        // 이동 거리 누적
        let currentAngles = SIMD3<Float>(pitch, yaw, roll)
        if let prev = previousAngles {
            totalMovementDistance += distance(prev, currentAngles)
        }
        previousAngles = currentAngles
    }

    /// 현재 위치를 기준점으로 캘리브레이션
    func calibrate() async {
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        guard let anchor = deviceAnchor else { return }

        let transform = anchor.originFromAnchorTransform
        let angles = extractEulerAngles(from: transform)
        calibrate(with: angles)
    }

    private func calibrate(with angles: SIMD3<Float>) {
        basePitch = angles.x
        baseYaw = angles.y
        baseRoll = angles.z
        isCalibrated = true
        print("[HeadTracking] Calibrated at pitch=\(basePitch)° yaw=\(baseYaw)° roll=\(baseRoll)°")
    }

    /// 머리가 목표 각도에 도달했는지 확인
    /// - Parameters:
    ///   - targetPitch: 목표 pitch 각도 (라디안)
    ///   - targetYaw: 목표 yaw 각도 (라디안)
    ///   - targetRoll: 목표 roll 각도 (라디안)
    ///   - threshold: 허용 오차 (라디안, 기본 10°)
    func isAtTarget(
        targetPitch: Float = 0,
        targetYaw: Float = 0,
        targetRoll: Float = 0,
        threshold: Float = 10 * .pi / 180
    ) -> Bool {
        let pitchDiff = abs(pitch - targetPitch)
        let yawDiff = abs(yaw - targetYaw)
        let rollDiff = abs(roll - targetRoll)

        return pitchDiff < threshold && yawDiff < threshold && rollDiff < threshold
    }

    /// SIMD3 형태의 목표와 비교 (x=yaw, y=pitch, z=roll)
    func isAtTarget(
        angles: SIMD3<Float>,
        threshold: Float = 10 * .pi / 180
    ) -> Bool {
        isAtTarget(
            targetPitch: angles.y,
            targetYaw: angles.x,
            targetRoll: angles.z,
            threshold: threshold
        )
    }

    /// 현재 각도와 목표 각도의 거리 (라디안)
    func distanceToTarget(angles: SIMD3<Float>) -> Float {
        let current = SIMD3<Float>(yaw, pitch, roll)
        return simd.distance(current, angles)
    }

    /// 안전 범위 내인지 확인
    var isInSafeRange: Bool {
        abs(pitch) <= Self.maxPitchRange &&
        abs(yaw) <= Self.maxYawRange &&
        abs(roll) <= Self.maxRollRange
    }

    /// 현재 범위 초과 경고 메시지
    var safetyWarning: String? {
        if abs(pitch) > Self.maxPitchRange {
            return pitch > 0 ? "너무 위를 보고 있습니다" : "너무 아래를 보고 있습니다"
        }
        if abs(yaw) > Self.maxYawRange {
            return yaw > 0 ? "너무 왼쪽으로 돌렸습니다" : "너무 오른쪽으로 돌렸습니다"
        }
        if abs(roll) > Self.maxRollRange {
            return roll > 0 ? "너무 오른쪽으로 기울였습니다" : "너무 왼쪽으로 기울였습니다"
        }
        return nil
    }

    func recordHit() {
        hitCount += 1
        totalAttempts += 1
    }

    func recordMiss() {
        totalAttempts += 1
    }

    func resetStats() {
        totalMovementDistance = 0
        previousAngles = nil
        hitCount = 0
        totalAttempts = 0
    }

    func stop() {
        arkitSession.stop()
        isTrackingActive = false
        isCalibrated = false
        print("[HeadTracking] Session stopped")
    }

    // MARK: - Euler Angle Extraction

    /// 4x4 변환 행렬에서 오일러 각도(pitch, yaw, roll) 추출
    private func extractEulerAngles(from transform: simd_float4x4) -> SIMD3<Float> {
        // 회전 행렬 요소
        let r00 = transform.columns.0.x
        let r10 = transform.columns.0.y
        let r20 = transform.columns.0.z
        let r21 = transform.columns.1.z
        let r22 = transform.columns.2.z

        // pitch (X축 회전) - 위아래
        let pitch = asin(-r20)

        // yaw (Y축 회전) - 좌우
        let yaw = atan2(r10, r00)

        // roll (Z축 회전) - 기울임
        let roll = atan2(r21, r22)

        return SIMD3<Float>(pitch, yaw, roll)
    }
}
