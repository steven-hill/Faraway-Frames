//
//  MockImageLoaderForUITests.swift
//  Faraway Frames
//
//  Created by Steven Hill on 18/02/2026.
//

import UIKit

final class MockImageLoaderForUITests: ImageLoader {
    func checkCache(for image: String) -> UIImage? {
        return nil
    }
    
    func loadImage(for image: String) async -> UIImage? {
        let image: UIImage?
        image = SFSymbols.popcorn
        return image
    }
}
