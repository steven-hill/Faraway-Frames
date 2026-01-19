//
//  FilmsListViewModelDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/01/2026.
//

import Foundation

protocol FilmsListViewModelDelegate: AnyObject {
    func didUpdateFilms(_ films: [Film])
    func didFailToLoadFilms(withError error: APIError)
}
