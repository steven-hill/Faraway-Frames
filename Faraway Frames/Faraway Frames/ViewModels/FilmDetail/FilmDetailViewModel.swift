//
//  FilmDetailViewModel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/02/2026.
//

import Foundation
import UIKit
import CoreData

final class FilmDetailViewModel: NSObject {
    
    // MARK: - State Definition
    enum FilmDetailState: Equatable {
        case noFilmSelected
        case content(displayModel: FilmDetailDisplayModel, image: UIImage? = nil)
        case fetchFailure(FilmDetailError, Film)
        case error(FilmDetailError, Film, FilmQueue)
    }
    
    // MARK: - Properties
    var film: Film?
    private let imageLoader: ImageLoader
    private let managedObjectContext: NSManagedObjectContext
    private var detailFRC: NSFetchedResultsController<FilmMO>?
    private let frcFactory: FilmDetailFRCFactory
    private let filmQueueService: FilmQueueServiceProtocol
    private(set) var imageLoadTask: Task<Void, Never>?
    private(set) var currentState: FilmDetailState = .noFilmSelected {
        didSet {
            updateUI()
        }
    }
    weak var delegate: FilmDetailViewModelDelegate?
    private(set) var attemptingToUpdateFilm = false
    private(set) var filmWasUpdated = false
    
    // MARK: - Initialisation
    init(imageLoader: ImageLoader,
        managedObjectContext: NSManagedObjectContext,
        frcFactory: FilmDetailFRCFactory,
        filmQueueService: FilmQueueServiceProtocol) {
        self.imageLoader = imageLoader
        self.managedObjectContext = managedObjectContext
        self.frcFactory = frcFactory
        self.filmQueueService = filmQueueService
        super.init()
    }
    
    //MARK: - Deinitialisation
    deinit {
        imageLoadTask?.cancel()
        imageLoadTask = nil
    }
    
    // MARK: - Methods
    func setFilm() {
        imageLoadTask?.cancel()
        
        guard let film = film else {
            detailFRC?.delegate = nil
            detailFRC = nil
            currentState = .noFilmSelected
            return
        }
        filmWasUpdated = false
        let displayModel = FilmDetailDisplayModel(film: film)
        currentState = .content(displayModel: displayModel)
        getMovieBanner(for: film, displayModel: displayModel)
    }
    
    func getMovieBanner(for film: Film, displayModel: FilmDetailDisplayModel) {
        let fallbackImage = SFSymbols.movieClapper
        imageLoadTask = Task { [weak self, displayModel] in
            guard let self, !Task.isCancelled else { return }
            let downloadedImage = await imageLoader.loadImage(for: film.movieBanner)
            guard !Task.isCancelled else { return }
            currentState = .content(displayModel: displayModel, image: downloadedImage ?? fallbackImage)
        }
    }
    
    /// Fetch the film from the database (if it exists there) so the film on `ExploreDetailVC` is in sync with what is in the database.
    func performFetch() {
        guard let film else { return }
        let frc = frcFactory.makeFilmDetailFRC(for: film.id,
                                               context: managedObjectContext)
        frc.delegate = self
        self.detailFRC = frc
        
        do {
            #if DEBUG
            try throwErrorForUITests()
            #endif
            
            try frc.performFetch()
        } catch {
            let reason = PersistenceFailureReason(from: error)
            let filmDetailError = FilmDetailError.fetchFailed(reason)
            currentState = .fetchFailure(filmDetailError, film)
        }
    }
    
    func updateUI() {
        switch currentState {
        case .noFilmSelected:
            delegate?.didUpdateWithEmptyState()
        case .content(_,_):
            delegate?.didUpdateFilmDetails()
        case .fetchFailure:
            delegate?.didReceiveError()
        case .error:
            delegate?.didReceiveError()
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
            attemptingToUpdateFilm = true
            
            #if DEBUG
            try throwErrorForUITests()
            #endif
         
            let didStatusChange = try await filmQueueService.updateFilmStatus(film: film, queue: queue, action: action)
            attemptingToUpdateFilm = false
            if didStatusChange {
                if case .content(let displayModel, let image) = currentState {
                    var updatedDisplayModel = displayModel
                    switch queue {
                    case .upNext: updatedDisplayModel.film.isUpNext = (action == .add)
                    case .watched: updatedDisplayModel.film.isWatched = (action == .add)
                    }
                    currentState = .content(displayModel: updatedDisplayModel, image: image)
                }
                filmWasUpdated = true
                notifyDelegateOfStatusChange(queue: queue, action: action)
            }
        } catch {
            let reason = PersistenceFailureReason(from: error)
            let filmDetailError = action == .add ? FilmDetailError.addFailed(reason) : FilmDetailError.removeFailed(reason)
            currentState = .error(filmDetailError, film, queue)
        }
    }
    
    //MARK: - Delegate Helper
    private func notifyDelegateOfStatusChange(queue: FilmQueue, action: QueueAction) {
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
    }
    
    func returnToFilmContent() {
        setFilm()
    }
}

// MARK: - Fetched Results Controller Delegate
extension FilmDetailViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let updatedFilmMO = controller.fetchedObjects?.first as? FilmMO
        handleFilmUpdate(updatedFilmMO)
    }
}

// MARK: - Film Mutation Logic
extension FilmDetailViewModel {
    func handleFilmUpdate(_ filmMO: FilmMO?) {
        /// Capture the existing image if we are in a content state.
        var currentImage: UIImage? = nil
        if case .content(_, let activeImage) = currentState {
            currentImage = activeImage
        }
        
        /// Handle deletion / empty state.
        guard let filmMO else {
            handleFilmDeletion(currentImage: currentImage)
            return
        }
        
        /// Handle update.
        let freshFilmData = Film(from: filmMO)
        handleFilmModification(freshFilmData, currentImage: currentImage)
    }
    
    private func handleFilmDeletion(currentImage: UIImage?) {
        guard case .content(let displayModel, _) = currentState else { return }
        
        var resetFilm = displayModel.film
        resetFilm.isUpNext = false
        resetFilm.isWatched = false
        
        let resetDisplayModel = FilmDetailDisplayModel(film: resetFilm)
        currentState = .content(displayModel: resetDisplayModel, image: currentImage)
        
        notifyDelegateOfStatusChange(queue: .upNext, action: .remove)
        notifyDelegateOfStatusChange(queue: .watched, action: .remove)
    }
    
    private func handleFilmModification(_ freshFilmData: Film, currentImage: UIImage?) {
        guard case .content(let oldDisplayModel, _) = currentState else { return }
        let oldFilm = oldDisplayModel.film
        
        let updatedDisplayModel = FilmDetailDisplayModel(film: freshFilmData)
        currentState = .content(displayModel: updatedDisplayModel, image: currentImage)
        
        if oldFilm.isUpNext != freshFilmData.isUpNext {
            let action: QueueAction = freshFilmData.isUpNext ? .add : .remove
            notifyDelegateOfStatusChange(queue: .upNext, action: action)
        }
        if oldFilm.isWatched != freshFilmData.isWatched {
            let action: QueueAction = freshFilmData.isWatched ? .add : .remove
            notifyDelegateOfStatusChange(queue: .watched, action: action)
        }
    }
}

// MARK: - Extension for setting up UI tests
private extension FilmDetailViewModel {
    private func throwErrorForUITests() throws {
        let processInfo = ProcessInfo.processInfo
        let isSaveError = processInfo.isUITestingPersistenceSaveError
        let isLoadError = processInfo.isUITestingExploreDetailVCPersistenceLoadError
        guard isSaveError || isLoadError else { return }
        
        let failureReason = processInfo.environment["MOCK_CD_FAILURE_REASON"]
        let errorCode: CocoaError.Code
        
        if isSaveError {
            errorCode = (failureReason == "diskFull") ? .fileWriteOutOfSpace : .persistentStoreOpen
        } else { 
            errorCode = (failureReason == "databaseError") ? .coreData : .persistentStoreOpen
        }
        
        throw CocoaError(errorCode)
    }
}
