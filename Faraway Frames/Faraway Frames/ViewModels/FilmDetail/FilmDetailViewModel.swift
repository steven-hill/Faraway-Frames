//
//  FilmDetailViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation
import UIKit
import CoreData

final class FilmDetailViewModel {
    
    // MARK: - State Definition
    enum FilmDetailState: Equatable {
        case noFilmSelected
        case content(displayModel: FilmDetailDisplayModel, image: UIImage? = nil)
    }
    
    // MARK: - Film Status Definition
    private enum FilmStatusProperty {
        case upNext
        case watched
    }
    
    // MARK: - Status Action Definition
    private enum StatusAction {
        case add
        case remove
    }
    
    // MARK: - Properties
    private let imageLoader: ImageLoader
    private let context: NSManagedObjectContext
    private(set) var imageLoadTask: Task<Void, Never>?
    private(set) var currentState: FilmDetailState = .noFilmSelected {
        didSet {
            updateUI()
        }
    }
    weak var delegate: FilmDetailViewModelDelegate?
    
    // MARK: - Initialisation
    init(film: Film? = nil, imageLoader: ImageLoader, context: NSManagedObjectContext) {
        self.imageLoader = imageLoader
        self.context = context
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
        
        init(film: Film) {
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
    
    // MARK: - Persistence methods
    func addFilmToUpNext(film: Film) async {
        await updateFilmStatus(film: film, property: .upNext) { [weak self] in
            self?.delegate?.didUpdateUpNextStatus(isUpNext: true)
        }
    }
    
    func removeFilmFromUpNext(film: Film) async {
        await updateFilmStatus(film: film, property: .upNext) { [weak self] in
            self?.delegate?.didUpdateUpNextStatus(isUpNext: false)
        }
    }
    
    func addFilmToWatched(film: Film) async {
        await updateFilmStatus(film: film, property: .watched) { [weak self] in
            self?.delegate?.didUpdateWatchedStatus(isWatched: true)
        }
    }
    
    private func updateFilmStatus(
        film: Film,
        property: FilmStatusProperty,
        onStatusChanged: @escaping @MainActor () -> Void
    ) async {
        do {
            let didStatusChange = try await context.perform { [context] in
                let request = NSFetchRequest<FilmMO>(entityName: "FilmMO")
                request.predicate = NSPredicate(format: "id == %@", film.id)
                
                let filmMO: FilmMO
                if let existing = try context.fetch(request).first {
                    filmMO = existing
                } else {
                    filmMO = Film.makeFilmMO(from: film, context: context)
                }
                
                let statusChanged: Bool
                
                switch property {
                case .upNext:
                    statusChanged = !filmMO.isUpNext
                    filmMO.isUpNext = true
                case .watched:
                    statusChanged = !filmMO.isWatched
                    filmMO.isWatched = true
                }
                
                if context.hasChanges {
                    try context.save()
                }
                return statusChanged
            }
            
            if didStatusChange {
                onStatusChanged()
            }
        } catch {
            // TODO: - handle error
            print("Failed to update film status: \(error)")
        }
    }
}
