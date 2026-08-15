//
//  ExploreDetailNavigationDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 15/08/2026.
//

import Foundation

protocol ExploreDetailNavigationDelegate: AnyObject {
    /// Notifies the delegate that the `More Like This` button was tapped.
    func exploreDetailDidTapMoreLikeThisButton()
}
