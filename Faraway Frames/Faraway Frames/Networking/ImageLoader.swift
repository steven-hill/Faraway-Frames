//
//  ImageLoader.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/01/2026.
//

import UIKit

protocol ImageLoader {
    func loadImage(for image: String) async -> UIImage?
    func checkCache(for image: String) -> UIImage?
}
