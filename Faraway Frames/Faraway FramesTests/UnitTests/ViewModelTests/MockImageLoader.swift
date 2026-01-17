//
//  MockImageLoader.swift
//  Faraway FramesTests
//
//  Created by Steven Hill on 17/01/2026.
//

import Foundation
import UIKit
@testable import Faraway_Frames

struct MockImageLoader: ImageLoader {
    var shouldSucceed: Bool = true
    
    func loadImage(from url: URL) async -> UIImage? {
        let image: UIImage?
        if shouldSucceed {
            image = UIImage(systemName: "popcorn")
        } else {
            return nil
        }
        return image
    }
}
