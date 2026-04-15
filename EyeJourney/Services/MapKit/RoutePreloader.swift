import MapKit
import SwiftUI

/// 경로의 다음 구간 맵 데이터를 사전에 로딩하여 끊김 없는 이동 경험 제공
@Observable
final class RoutePreloader {

    /// 프리로드 상태
    enum PreloadState {
        case idle
        case loading(progress: Float)
        case ready
        case failed(String)
    }

    var state: PreloadState = .idle

    /// 프리로드된 Look Around 장면 캐시
    private var lookAroundCache: [String: MKLookAroundScene] = [:]

    /// 프리로드된 스텝 인덱스 범위
    private var preloadedRange: Range<Int> = 0..<0

    /// 프리로드 선행 구간 수 (현재 위치 기준 앞으로 몇 스텝을 미리 로딩)
    private let lookAheadCount = 5

    /// 전체 경로 프리로드 작업
    private var preloadTask: Task<Void, Never>?

    // MARK: - 초기 프리로드

    /// 경로 시작 전 초반 구간을 미리 로딩
    /// - Parameters:
    ///   - steps: 전체 보간된 경로 스텝
    ///   - initialCount: 처음에 프리로딩할 스텝 수
    func preloadInitialSegment(
        steps: [PathInterpolator.CameraStep],
        initialCount: Int = 10
    ) async {
        state = .loading(progress: 0)
        let count = min(initialCount, steps.count)

        for i in 0..<count {
            guard !Task.isCancelled else { return }
            await preloadStep(steps[i])
            state = .loading(progress: Float(i + 1) / Float(count))
        }

        preloadedRange = 0..<count
        state = .ready
    }

    // MARK: - 진행형 프리로드

    /// 현재 스텝에 도달했을 때 다음 구간을 백그라운드로 프리로드
    /// - Parameters:
    ///   - currentIndex: 현재 진행 중인 스텝 인덱스
    ///   - steps: 전체 경로 스텝
    func onStepReached(currentIndex: Int, steps: [PathInterpolator.CameraStep]) {
        // 이미 프리로드된 범위면 스킵
        let targetEnd = min(currentIndex + lookAheadCount, steps.count)
        guard targetEnd > preloadedRange.upperBound else { return }

        // 기존 프리로드 작업 취소 방지 (중복 방지)
        preloadTask?.cancel()
        preloadTask = Task {
            let start = preloadedRange.upperBound
            for i in start..<targetEnd {
                guard !Task.isCancelled else { return }
                await preloadStep(steps[i])
            }
            preloadedRange = preloadedRange.lowerBound..<targetEnd
        }
    }

    // MARK: - Look Around 프리로드

    /// Look Around 장면을 미리 요청하여 캐시
    func preloadLookAround(for coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
        let key = coordinateKey(coordinate)

        // 캐시에 있으면 반환
        if let cached = lookAroundCache[key] {
            return cached
        }

        // 새로 요청
        do {
            let request = MKLookAroundSceneRequest(coordinate: coordinate)
            let scene = try await request.scene
            if let scene {
                lookAroundCache[key] = scene
            }
            return scene
        } catch {
            print("[Preloader] Look Around not available at \(coordinate): \(error.localizedDescription)")
            return nil
        }
    }

    /// 캐시된 Look Around 장면 조회
    func cachedLookAround(for coordinate: CLLocationCoordinate2D) -> MKLookAroundScene? {
        lookAroundCache[coordinateKey(coordinate)]
    }

    /// 특정 좌표에 Look Around가 가능한지 확인 (캐시 기반)
    func isLookAroundAvailable(for coordinate: CLLocationCoordinate2D) -> Bool {
        lookAroundCache[coordinateKey(coordinate)] != nil
    }

    // MARK: - 맵 타일 프리로드

    /// 특정 스텝의 맵 데이터를 사전 로딩
    /// MapKit은 직접적인 타일 프리로드 API가 없으므로
    /// MKMapSnapshotter로 해당 영역의 타일을 미리 요청하여 시스템 캐시에 적재
    private func preloadStep(_ step: PathInterpolator.CameraStep) async {
        // 1) 맵 스냅샷으로 타일 캐시 워밍
        let options = MKMapSnapshotter.Options()
        options.camera = MKMapCamera(
            lookingAtCenter: step.coordinate,
            fromDistance: step.distance,
            pitch: step.pitch,
            heading: step.heading
        )
        options.size = CGSize(width: 256, height: 256) // 최소 크기로 빠르게
        options.mapType = .satelliteFlyover

        let snapshotter = MKMapSnapshotter(options: options)
        do {
            _ = try await snapshotter.start()
        } catch {
            // 프리로드 실패는 무시 (네트워크 문제 등)
        }

        // 2) Look Around 장면 프리로드 (웨이포인트만)
        if step.isWaypoint {
            _ = await preloadLookAround(for: step.coordinate)
        }
    }

    // MARK: - 유틸리티

    private func coordinateKey(_ coordinate: CLLocationCoordinate2D) -> String {
        String(format: "%.5f,%.5f", coordinate.latitude, coordinate.longitude)
    }

    /// 캐시 클리어
    func clearCache() {
        lookAroundCache.removeAll()
        preloadedRange = 0..<0
        preloadTask?.cancel()
        state = .idle
    }
}
