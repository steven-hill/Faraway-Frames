//
//  HomeViewModelCoordinatorDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 21/07/2026.
//

import Foundation

protocol HomeViewModelCoordinatorDelegate: AnyObject {
    func homeViewModelDidCaptureFilm(_ film: Film)
}
