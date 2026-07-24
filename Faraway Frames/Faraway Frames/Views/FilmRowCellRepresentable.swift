//
//  FilmRowCellRepresentable.swift
//  Faraway Frames
//
//  Created by Steven Hill on 24/07/2026.
//

import UIKit

protocol FilmRowCellRepresentable: AnyObject {
    var imageTask: Task<Void, Never>? { get set }
    func configureTitle(with title: String)
    func configureImage(with image: UIImage?)
}

extension FilmRowCell: FilmRowCellRepresentable {}
