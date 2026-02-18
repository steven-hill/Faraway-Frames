//
//  MockImageLoaderForUITests.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import UIKit

final class MockImageLoaderForUITests: ImageLoader {
    func loadImage(from url: URL) async -> UIImage? {
        let image: UIImage?
        image = UIImage(systemName: "popcorn")
        return image
    }
}
