import SwiftUI

/// 목 운동 시 화면에 표시되는 가이드 뷰
/// 머리를 어느 방향으로 움직여야 하는지 시각적으로 안내
struct NeckExerciseGuideView: View {
    let exerciseType: ExerciseType
    let targetAngles: SIMD3<Float>  // x=yaw, y=pitch, z=roll (라디안)
    let currentPitch: Float
    let currentYaw: Float
    let currentRoll: Float
    let dwellProgress: Float
    var safetyWarning: String?

    private var targetPitchDeg: Float { targetAngles.y * 180 / .pi }
    private var targetYawDeg: Float { targetAngles.x * 180 / .pi }
    private var currentPitchDeg: Float { currentPitch * 180 / .pi }
    private var currentYawDeg: Float { currentYaw * 180 / .pi }

    var body: some View {
        ZStack {
            // 목 방향 가이드
            directionGuide
                .frame(width: 300, height: 300)

            // 안전 경고
            if let warning = safetyWarning {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(warning)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.red.opacity(0.8), in: Capsule())
                    .padding(.bottom, 40)
                }
            }

            // 운동 안내 텍스트
            VStack {
                instructionBadge
                Spacer()
            }
            .padding(.top, 16)
        }
    }

    // MARK: - Direction Guide

    private var directionGuide: some View {
        ZStack {
            // 외곽 링
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 2)

            // 안전 범위 표시
            Circle()
                .stroke(.green.opacity(0.15), lineWidth: 40)
                .frame(width: 220, height: 220)

            // 십자 가이드라인
            crosshair

            // 목표 위치 (가야 할 곳)
            targetIndicator
                .offset(
                    x: CGFloat(targetYawDeg) * 2.5,
                    y: CGFloat(-targetPitchDeg) * 2.5
                )

            // 현재 위치 (머리 방향)
            currentPositionIndicator
                .offset(
                    x: CGFloat(currentYawDeg) * 2.5,
                    y: CGFloat(-currentPitchDeg) * 2.5
                )

            // 기울임 표시 (roll 전용)
            if exerciseType == .neckLateralTilt {
                rollIndicator
            }
        }
    }

    private var crosshair: some View {
        ZStack {
            // 수평선
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 280, height: 1)
            // 수직선
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1, height: 280)
        }
    }

    private var targetIndicator: some View {
        ZStack {
            // 타겟 원
            Circle()
                .fill(.blue.opacity(0.3))
                .frame(width: 50, height: 50)

            // dwell 진행 링
            Circle()
                .trim(from: 0, to: CGFloat(dwellProgress))
                .stroke(.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))

            // 방향 화살표
            directionArrow
        }
        .animation(.easeInOut(duration: 0.3), value: targetAngles.x)
        .animation(.easeInOut(duration: 0.3), value: targetAngles.y)
    }

    @ViewBuilder
    private var directionArrow: some View {
        let angle = atan2(targetAngles.y, targetAngles.x)
        if simd.length(SIMD2<Float>(targetAngles.x, targetAngles.y)) > 0.02 {
            Image(systemName: "arrow.up")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .rotationEffect(.radians(Double(-angle + .pi / 2)))
        } else {
            Image(systemName: "circle.fill")
                .font(.caption)
                .foregroundStyle(.blue)
        }
    }

    private var currentPositionIndicator: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 16, height: 16)
            Circle()
                .fill(.cyan)
                .frame(width: 12, height: 12)
        }
        .shadow(color: .cyan.opacity(0.5), radius: 8)
        .animation(.easeOut(duration: 0.1), value: currentPitchDeg)
        .animation(.easeOut(duration: 0.1), value: currentYawDeg)
    }

    private var rollIndicator: some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                // 왼쪽 기울임
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(currentRoll < -0.05 ? .cyan : .white.opacity(0.3))
                    .font(.title2)

                // 현재 기울기 바
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white.opacity(0.3))
                    .frame(width: 120, height: 8)
                    .overlay(alignment: .center) {
                        Circle()
                            .fill(.cyan)
                            .frame(width: 14, height: 14)
                            .offset(x: CGFloat(currentRoll * 180 / .pi) * 2)
                    }

                // 오른쪽 기울임
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(currentRoll > 0.05 ? .cyan : .white.opacity(0.3))
                    .font(.title2)
            }
            .padding(.bottom, 8)
        }
    }

    // MARK: - Instruction Badge

    private var instructionBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: exerciseType.iconName)
            Text(instructionText)
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var instructionText: String {
        switch exerciseType {
        case .neckFlexion:
            if targetAngles.y > 0.05 {
                return "고개를 위로 들어주세요"
            } else if targetAngles.y < -0.05 {
                return "고개를 아래로 숙여주세요"
            }
            return "정면을 바라보세요"
        case .neckRotation:
            if targetAngles.x > 0.05 {
                return "왼쪽으로 고개를 돌리세요"
            } else if targetAngles.x < -0.05 {
                return "오른쪽으로 고개를 돌리세요"
            }
            return "정면을 바라보세요"
        case .neckLateralTilt:
            if targetAngles.z > 0.05 {
                return "오른쪽으로 기울이세요"
            } else if targetAngles.z < -0.05 {
                return "왼쪽으로 기울이세요"
            }
            return "정면을 바라보세요"
        case .neckCircle:
            return "원형으로 목을 돌리세요"
        default:
            return ""
        }
    }
}
