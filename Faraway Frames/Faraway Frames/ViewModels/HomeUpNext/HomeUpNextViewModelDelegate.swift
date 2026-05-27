//
//  HomeUpNextViewModelDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 29/03/2026.
//

import Foundation

protocol HomeUpNextViewModelDelegate: AnyObject {
    func upNextFilmsDidChange(_ films:[FilmWithStatus])
}
