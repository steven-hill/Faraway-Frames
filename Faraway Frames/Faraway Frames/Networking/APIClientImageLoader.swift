//
//  APIClientImageLoader.swift
//  Faraway Frames
//
//  Created by Steven Hill on 17/01/2026.
//

import UIKit

struct APIClientImageLoader: ImageLoader {
    func loadImage(from url: URL) async -> UIImage? {
        let image: UIImage?
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            image = UIImage(data: data)
        } catch {
            return nil
        }
        return image
    } 
}
