//
//  HomeCoordinatorDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 21/07/2026.
//

import Foundation

protocol HomeCoordinatorDelegate: AnyObject {
    func homeCoordinatorDidRequestNavigationToExploreTab(for film: Film)
}
