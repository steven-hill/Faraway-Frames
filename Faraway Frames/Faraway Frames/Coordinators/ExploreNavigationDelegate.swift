//
//  ExploreNavigationDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation

protocol ExploreNavigationDelegate: AnyObject {
    var shouldDeselectAfterSelection: Bool { get }
    func didSelectFilm(_ film: Film)
    func didTapMoreLikeThisButton()
}
