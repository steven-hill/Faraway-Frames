//
//  FilmDetailViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation
import UIKit

final class FilmDetailViewModel {
    
    // MARK: - State Definition
    enum FilmDetailState: Equatable {
        case noFilmSelected
        case content(displayModel: FilmDetailDisplayModel, image: UIImage? = nil)
    }
    
    // MARK: - Properties
    private let imageLoader: ImageLoader
    private(set) var imageLoadTask: Task<Void, Never>?
    private(set) var currentState: FilmDetailState = .noFilmSelected {
        didSet {
            updateUI()
        }
    }
    weak var delegate: FilmDetailViewModelDelegate?
    
    // MARK: - Initialisation
    init(film: Film? = nil, imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        if let film {
            setFilm(film)
        }
    }
    
    // MARK: - Methods
    func setFilm(_ film: Film?) {
        imageLoadTask?.cancel()
        
        guard let film = film else {
            currentState = .noFilmSelected
            return
        }
        currentState = .content(film)
        getMovieBanner(for: film)
    }
    
    func updateUI() {
        switch currentState {
        case .noFilmSelected:
            delegate?.didUpdateWithEmptyState()
        case .content(_,_):
            delegate?.didUpdateFilmDetails()
        }
    }
    
    func getMovieBanner(for film: Film) {
        let fallbackImage = SFSymbols.movieClapper
        guard let url = URL(string: film.movieBanner) else {
            currentState = .content(film, image: fallbackImage)
            return
        }
        
        imageLoadTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            let downloadedImage = await imageLoader.loadImage(from: url)
            if !Task.isCancelled {
                currentState = .content(film, image: downloadedImage ?? fallbackImage)
            } else {
                currentState = .content(film, image: fallbackImage)
            }
        }
    }
    
    // MARK: - Presentation data structure
    struct FilmDetailDisplayModel {
        let title: String
        let visualOriginalTitles: String
        let spokenJapaneseTitle: NSAttributedString
        let releaseYearAndDurationText: String
        let releaseYearAndDurationAccessibilityLabel: String
        let synopsisTitle: String = NSLocalizedString("Synopsis", comment: "")
        let synopsisDescription: String
        let rottenTomatoesScoreText: NSAttributedString
        let director: String
        let producer: String
        let creditsAccessibilityLabel: String
        
        init(film: Film, scoreFormatter: (String) -> NSAttributedString) {
            self.title = film.title
            self.visualOriginalTitles = "\(film.originalTitle)\n\(film.originalTitleRomanised)"
            self.synopsisDescription = film.description
            self.director = film.director
            self.producer = film.producer
            
            self.releaseYearAndDurationText = "\(film.releaseDate) • \(film.runningTime) mins"
            self.releaseYearAndDurationAccessibilityLabel = "Released in \(film.releaseDate), running time \(film.runningTime) minutes."
            self.creditsAccessibilityLabel = "Credits. Directed by \(film.director). Produced by \(film.producer)."
            self.rottenTomatoesScoreText = scoreFormatter(film.rottenTomatoesScore)
            
            let prefix = "Original title: "
            let combinedString = NSMutableAttributedString(string: "\(prefix)\(film.originalTitle)")
            let prefixLength = (prefix as NSString).length
            let japaneseLength = (film.originalTitle as NSString).length
            combinedString.addAttribute(
                .accessibilitySpeechLanguage,
                value: "ja",
                range: NSRange(location: prefixLength, length: japaneseLength)
            )
            self.spokenJapaneseTitle = combinedString
        }
    }
}
