//
//  CacheManagerProtocol.swift
//  Faraway Frames
//
//  Created by Steven Hill on 25/01/2026.
//

import UIKit

protocol CacheManagerProtocol {
    func getData(forKey key: NSString) -> UIImage?
    func setData(_ image: UIImage, forKey key: NSString)
}
