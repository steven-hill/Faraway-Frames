//
//  MockImageLoader.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/01/2026.
//

import Foundation
import UIKit
@testable import Faraway_Frames

final class MockImageLoader: ImageLoader {
    var shouldSucceed: Bool = true
    
    func loadImage(for image: String) async -> UIImage? {
        let image: UIImage?
        if shouldSucceed {
            image = SFSymbols.popcorn
        } else {
            return nil
        }
        return image
    }
    
    func checkCache(for image: String) -> UIImage? {
        return nil
    }
}
