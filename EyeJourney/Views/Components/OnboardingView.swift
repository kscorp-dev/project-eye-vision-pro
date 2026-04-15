import SwiftUI

/// 첫 실행 시 온보딩 튜토리얼
struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "eye.circle.fill",
            title: "EyeJourney에 오신 걸 환영합니다",
            description: "눈으로 떠나는 세계여행을 통해\n자연스럽게 안구운동을 할 수 있습니다",
            color: .blue
        ),
        OnboardingPage(
            iconName: "viewfinder.circle.fill",
            title: "시선으로 조작하세요",
            description: "화면에 나타나는 가이드 포인트를\n시선으로 따라가면 됩니다\n컨트롤러가 필요 없어요",
            color: .green
        ),
        OnboardingPage(
            iconName: "map.circle.fill",
            title: "세계를 탐험하세요",
            description: "제주도, 스위스, 산토리니, 아이슬란드\n아름다운 풍경 속에서 운동하세요",
            color: .orange
        ),
        OnboardingPage(
            iconName: "flame.circle.fill",
            title: "매일 꾸준히",
            description: "일일 미션과 연속 기록으로\n건강한 눈 습관을 만들어보세요",
            color: .red
        ),
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // 페이지 콘텐츠
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 350)

            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? .blue : .gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()

            // 버튼
            HStack(spacing: 16) {
                if currentPage > 0 {
                    Button("이전") {
                        withAnimation { currentPage -= 1 }
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("다음") {
                        withAnimation { currentPage += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("시작하기") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .padding()
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            Image(systemName: page.iconName)
                .font(.system(size: 70))
                .foregroundStyle(page.color.gradient)

            Text(page.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
}

private struct OnboardingPage {
    let iconName: String
    let title: String
    let description: String
    let color: Color
}
