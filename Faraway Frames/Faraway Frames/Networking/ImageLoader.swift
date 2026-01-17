//
//  ImageLoader.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/01/2026.
//

import UIKit

protocol ImageLoader {
    func loadImage(from url: URL) async -> UIImage?
}
