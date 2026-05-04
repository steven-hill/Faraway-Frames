//
//  ExploreDetailMovieBannerMockImageLoader.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 07/02/2026.
//

import Foundation
import UIKit
@testable import Faraway_Frames

final class ExploreDetailMovieBannerMockImageLoader: ImageLoader {
    var loadCount = 0
    private var continuation: CheckedContinuation<UIImage?, Never>?
    func loadImage(from url: URL) async -> UIImage? {
        loadCount += 1
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func resume(shouldSucceed: Bool) {
        let image = shouldSucceed ? SFSymbols.popcorn : SFSymbols.movieClapper
        continuation?.resume(returning: image)
        continuation = nil
    }
}
