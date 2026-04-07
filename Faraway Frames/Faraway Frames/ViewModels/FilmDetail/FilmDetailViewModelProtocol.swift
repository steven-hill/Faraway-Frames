//
//  FilmDetailViewModelProtocol.swift
//  Faraway Frames
//
//  Created by Steven Hill on 06/04/2026.
//

import Foundation

protocol FilmDetailViewModelProtocol: AnyObject {
    var delegate: FilmDetailViewModelDelegate? { get set }
    var currentState: FilmDetailViewModel.FilmDetailState { get }
    func setFilm(_ film: Film?)
    func cancelImageLoad()
}
