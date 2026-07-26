//
//  HomeViewModelDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/06/2026.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {
    func filmsDidChange()
    func didReceiveError(_ error: HomeError)
}
