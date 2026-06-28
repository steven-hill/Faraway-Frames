//
//  FilmDetailViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation
import UIKit
import CoreData

class FilmDetailViewModel {
    
    // MARK: - State Definition
    enum FilmDetailState: Equatable {
        case noFilmSelected
        case content(displayModel: FilmDetailDisplayModel, image: UIImage? = nil)
        case error(FilmDetailError)
    }
    
    // MARK: - Properties
    private let imageLoader: ImageLoader
    private let filmQueueService: FilmQueueService
    private(set) var imageLoadTask: Task<Void, Never>?
    private(set) var currentState: FilmDetailState = .noFilmSelected {
        didSet {
            updateUI()
        }
    }
    weak var delegate: FilmDetailViewModelDelegate?
    private(set) var hasChanges = false
    
    // MARK: - Initialisation
    init(film: Film? = nil,
        imageLoader: ImageLoader,
        filmQueueService: FilmQueueService) {
        self.imageLoader = imageLoader
        self.filmQueueService = filmQueueService
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
        hasChanges = false
        let displayModel = FilmDetailDisplayModel(film: film)
        currentState = .content(displayModel: displayModel)
        getMovieBanner(for: film, displayModel: displayModel)
    }
    
    func updateUI() {
        switch currentState {
        case .noFilmSelected:
            delegate?.didUpdateWithEmptyState()
        case .content(_,_):
            delegate?.didUpdateFilmDetails()
        case .error:
            delegate?.didReceiveError()
        }
    }
    
    func getMovieBanner(for film: Film, displayModel: FilmDetailDisplayModel) {
        let fallbackImage = SFSymbols.movieClapper
        guard let url = URL(string: film.movieBanner) else {
            currentState = .content(displayModel: displayModel, image: fallbackImage)
            return
        }
        
        imageLoadTask = Task { [weak self, displayModel] in
            guard let self, !Task.isCancelled else { return }
            let downloadedImage = await imageLoader.loadImage(from: url)
            guard !Task.isCancelled else { return }
            currentState = .content(displayModel: displayModel, image: downloadedImage ?? fallbackImage)
        }
    }
    
    // MARK: - Presentation data structure
    struct FilmDetailDisplayModel: Equatable {
        var film: Film
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
        var isUpNext: Bool { film.isUpNext }
        var isWatched: Bool { film.isWatched }
        
        init(film: Film) {
            self.film = film
            self.title = film.title
            self.visualOriginalTitles = "\(film.originalTitle)\n\(film.originalTitleRomanised)"
            self.synopsisDescription = film.description
            self.director = film.director
            self.producer = film.producer
            self.releaseYearAndDurationText = "\(film.releaseDate) • \(film.runningTime) mins"
            self.releaseYearAndDurationAccessibilityLabel = "Released in \(film.releaseDate), running time \(film.runningTime) minutes."
            self.creditsAccessibilityLabel = "Credits. Directed by \(film.director). Produced by \(film.producer)."
            
            let fullScoreText = "Rotten Tomatoes \(film.rottenTomatoesScore)%"
            let scoreAttributedString = NSMutableAttributedString(string: fullScoreText)
            let rtRange = NSRange(location: 0, length: 16)
            scoreAttributedString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: rtRange)
            let scoreRange = NSRange(location: 16, length: (fullScoreText as NSString).length - 16)
            scoreAttributedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: scoreRange)
            self.rottenTomatoesScoreText = scoreAttributedString
            
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
    
    // MARK: - Persistence method
    func updateStatus(for film: Film, queue: FilmQueue, action: QueueAction) async {
        do {
            let didStatusChange = try await filmQueueService.updateFilmStatus(film: film, queue: queue, action: action)
            
            if didStatusChange {
                if case .content(let displayModel, let image) = currentState {
                    var updatedDisplayModel = displayModel
                    switch queue {
                    case .upNext: updatedDisplayModel.film.isUpNext = (action == .add)
                    case .watched: updatedDisplayModel.film.isWatched = (action == .add)
                    }
                    currentState = .content(displayModel: updatedDisplayModel, image: image)
                }
                
                switch (queue, action) {
                case (.upNext, .add):
                    delegate?.didUpdateUpNextStatus(isUpNext: true)
                case (.upNext, .remove):
                    delegate?.didUpdateUpNextStatus(isUpNext: false)
                case (.watched, .add):
                    delegate?.didUpdateWatchedStatus(isWatched: true)
                case (.watched, .remove):
                    delegate?.didUpdateWatchedStatus(isWatched: false)
                }
                hasChanges = true
            }
        } catch {
            let filmDetailError = action == .add ? FilmDetailError.add(error) : FilmDetailError.delete(error)
            currentState = .error(filmDetailError)
        }
    }
}
