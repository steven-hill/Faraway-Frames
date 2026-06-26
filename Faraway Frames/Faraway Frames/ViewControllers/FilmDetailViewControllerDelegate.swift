//
//  FilmDetailViewControllerDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 26/06/2026.
//

import Foundation

protocol FilmDetailViewControllerDelegate: AnyObject {
    /// Notifies the delegate that a single film's local state has mutated
    func filmDetailViewController(_ controller: ExploreDetailVC, didUpdateFilm updatedFilm: Film)
}
