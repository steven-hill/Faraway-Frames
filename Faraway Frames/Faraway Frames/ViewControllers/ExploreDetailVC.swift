//
//  ExploreDetailViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreDetailVC: UIViewController {
    
    // MARK: - Properties
    private(set) var isUpNext: Bool = false {
        didSet { updateUpNextButtonUI() }
    }
    private(set) var isWatched: Bool = false {
        didSet { updateWatchedButtonUI() }
    }
    weak var delegate: FilmDetailViewControllerDelegate?
    let filmDetailViewModel: FilmDetailViewModel
    private(set) var updatedFilm: Film? = nil
    private var movieBannerHeightConstraint: NSLayoutConstraint?
    private var contentViewLeadingConstraint: NSLayoutConstraint?
    private var contentViewTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let movieBanner: UIImageView = {
        let movieBanner = UIImageView()
        movieBanner.clipsToBounds = true
        movieBanner.layer.cornerRadius = 12
        movieBanner.translatesAutoresizingMaskIntoConstraints = false
        movieBanner.accessibilityIdentifier = "ExploreDetailVC_MovieBanner"
        movieBanner.isAccessibilityElement = false
        return movieBanner
    }()
    
    private let titleLabel = FFLabel(font: .preferredFont(forTextStyle: .extraLargeTitle2), textColor: .label, accessibilityIdentifer: "ExploreDetailVC_TitleLabel", accessibilityTraits: .header)

    private let originalTitlesLabel = FFLabel(font: .preferredFont(forTextStyle: .title2), textColor: .secondaryLabel, accessibilityIdentifer: "ExploreDetailVC_OriginalTitlesLabel")

    private let releaseDateAndRunningTimeLabel = FFLabel(font: .preferredFont(forTextStyle: .title2), textColor: .secondaryLabel, accessibilityIdentifer: "ExploreDetailVC_ReleaseDateAndRunningTimeLabel")

    private let rottenTomatoesScoreLabel = FFLabel(font: .preferredFont(forTextStyle: .title2), textColor: nil, accessibilityIdentifer: "ExploreDetailVC_RottenTomatoesScoreLabel")
    
    private let synopsisHeaderLabel = FFLabel(font: .preferredFont(forTextStyle: .headline), textColor: .label, accessibilityIdentifer: "ExploreDetailVC_SynopsisHeaderLabel", accessibilityTraits: .header)
    
    private let synopsisLabel = FFLabel(font: .preferredFont(forTextStyle: .body), textColor: .label, accessibilityIdentifer: "ExploreDetailVC_SynopsisLabel")
    
    private let creditsContainer: FilmCreditsStackView = {
        let creditsContainer = FilmCreditsStackView()
        creditsContainer.spacing = 20
        creditsContainer.translatesAutoresizingMaskIntoConstraints = false
        creditsContainer.isAccessibilityElement = true
        creditsContainer.accessibilityIdentifier = "ExploreDetailVC_CreditsContainer"
        return creditsContainer
    }()
    
    let upNextButton = FFButton(title: "", systemImageName: "", accessibilityIdentifier: "ExploreDetailVC_UpNextButton", accessibilityHint: "")

    let watchedButton = FFButton(title: "", systemImageName: "", accessibilityIdentifier: "ExploreDetailVC_WatchedButton", accessibilityHint: "")

    private let moreLikeThisButton = FFButton(title: "More Like This", systemImageName: "sparkles", accessibilityIdentifier: "ExploreDetailVC_MoreLikeThisButton", accessibilityHint: "Discover more films you might like")
    
    private let buttonsContainer: UIStackView = {
        let buttonsContainer = UIStackView()
        buttonsContainer.spacing = 20
        buttonsContainer.distribution = .fillEqually
        buttonsContainer.alignment = .fill
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.accessibilityIdentifier = "ExploreDetailVC_ButtonsContainer"
        return buttonsContainer
    }()
    
    // MARK: - Initialisation
    init(filmDetailViewModel: FilmDetailViewModel) {
        self.filmDetailViewModel = filmDetailViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tertiarySystemBackground
        navigationItem.largeTitleDisplayMode = .never
        filmDetailViewModel.delegate = self
        setupButtonsContainer()
        setupButtonActions()
        setupScrollView()
        addSubviews()
        setupConstraints()
        registerForTraitChanges([UITraitHorizontalSizeClass.self]) {
            (self: Self, previousTraitCollection: UITraitCollection) in
            self.updateLayoutForTraits()
        }
        updateLayoutForTraits()
    }
    
    private func updateLayoutForTraits() {
        creditsContainer.axis = (traitCollection.horizontalSizeClass == .regular) ? .horizontal : .vertical
        creditsContainer.distribution = (traitCollection.horizontalSizeClass == .regular) ? .fillEqually : .fill
        buttonsContainer.axis = (traitCollection.horizontalSizeClass == .regular) ? .horizontal: .vertical
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        var config: UIContentUnavailableConfiguration? = nil
        switch filmDetailViewModel.currentState {
        case .noFilmSelected:
            config = createEmptyState()
            buttonsContainer.isHidden = true
        case .content(let displayModel, let image):
            config = nil
            createContent(displayModel: displayModel, image: image)
            contentView.isHidden = false
            buttonsContainer.isHidden = false
            self.isUpNext = displayModel.isUpNext
            self.isWatched = displayModel.isWatched
            updatedFilm = displayModel.film
        case .error(let error, let film, let queue):
            config = createErrorConfig(error: error, film: film, queue: queue)
            navigationItem.hidesBackButton = true
            contentView.isHidden = true
            buttonsContainer.isHidden = true
        }
        self.contentUnavailableConfiguration = config
    }
    
    private func createEmptyState() -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = SFSymbols.movieClapper
        config.text = "No Film Selected"
        config.secondaryText = "Select a film from the list for more details."
        return config
    }
    
    private func createContent(displayModel: FilmDetailViewModel.FilmDetailDisplayModel, image: UIImage?) {
        movieBanner.image = image
        movieBanner.contentMode = (movieBanner.image == SFSymbols.movieClapper) ? .scaleAspectFit : .scaleAspectFill
        titleLabel.text = displayModel.title
        originalTitlesLabel.text = displayModel.visualOriginalTitles
        originalTitlesLabel.accessibilityAttributedLabel = displayModel.spokenJapaneseTitle
        releaseDateAndRunningTimeLabel.text = displayModel.releaseYearAndDurationText
        releaseDateAndRunningTimeLabel.accessibilityLabel = displayModel.releaseYearAndDurationAccessibilityLabel
        synopsisHeaderLabel.text = displayModel.synopsisTitle
        synopsisLabel.text = displayModel.synopsisDescription
        rottenTomatoesScoreLabel.attributedText = displayModel.rottenTomatoesScoreText
        creditsContainer.configure(
            withDirector: displayModel.director,
            producer: displayModel.producer,
            accessibilityLabelText: displayModel.creditsAccessibilityLabel
        )
    }
    
    private func createErrorConfig(error: FilmDetailError, film: Film, queue: FilmQueue) -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.empty()
        config.text = "Error"
        config.secondaryText = "\(error.description)"
        config.image = SFSymbols.exclamationMarkTriangle
        config.imageProperties.tintColor = .systemRed
        
        config.button = .prominentGlass()
        config.button.title = "Retry"
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            guard let self else { return }
            let action: QueueAction = error == .add(error) ? .add : .remove
            Task {
                await filmDetailViewModel.updateStatus(for: film, queue: queue, action: action)
            }
            self.setNeedsUpdateContentUnavailableConfiguration()
        }
        
        config.secondaryButton = .plain()
        config.secondaryButton.title = "Cancel"
        config.secondaryButtonProperties.primaryAction = UIAction { [weak self] _ in
            guard let self else { return }
            let button = queue == .upNext ? upNextButton : watchedButton
            setButtonEnabled(true, button: button)
            filmDetailViewModel.returnToFilmContent(film: film)
            self.setNeedsUpdateContentUnavailableConfiguration()
        }
        return config
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateLayoutFor(size: size)
            self.view.layoutIfNeeded()
        })
    }

    private func updateLayoutFor(size: CGSize) {
        movieBannerHeightConstraint?.isActive = false
        contentViewLeadingConstraint?.isActive = false
        contentViewTrailingConstraint?.isActive = false
        
        let isPortrait = size.height >= size.width
        let isCompact = CurrentDevice.isIPad ? traitCollection.horizontalSizeClass == .compact : isPortrait
        let multiplier: CGFloat = isCompact ? 0.3 : 0.75
        movieBannerHeightConstraint = movieBanner.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier)
        
        if CurrentDevice.isIPad || isPortrait {
            contentViewLeadingConstraint = contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            contentViewTrailingConstraint = contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        } else {
            contentViewLeadingConstraint = contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            contentViewTrailingConstraint = contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        }
        
        movieBannerHeightConstraint?.isActive = true
        contentViewLeadingConstraint?.isActive = true
        contentViewTrailingConstraint?.isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if movieBannerHeightConstraint == nil || contentViewLeadingConstraint == nil || contentViewTrailingConstraint == nil {
            updateLayoutFor(size: view.bounds.size)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard filmDetailViewModel.hasChanges else { return }
        if let film = updatedFilm {
            delegate?.filmDetailViewController(self, didUpdateFilm: film)
        }
    }
    
    // MARK: - UI Components Setup
    private func setupScrollView() {
        scrollView.bouncesVertically = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupButtonsContainer() {
        buttonsContainer.addArrangedSubview(upNextButton)
        buttonsContainer.addArrangedSubview(watchedButton)
        buttonsContainer.addArrangedSubview(moreLikeThisButton)
        buttonsContainer.isHidden = true
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(movieBanner)
        contentView.addSubview(titleLabel)
        contentView.addSubview(originalTitlesLabel)
        contentView.addSubview(releaseDateAndRunningTimeLabel)
        contentView.addSubview(synopsisHeaderLabel)
        contentView.addSubview(synopsisLabel)
        contentView.addSubview(rottenTomatoesScoreLabel)
        contentView.addSubview(creditsContainer)
        contentView.addSubview(buttonsContainer)
    }
    
    // MARK: - Buttons UI Updates
    private func updateUpNextButtonUI() {
        if isUpNext {
            upNextButton.update(
                title: "Remove from Up Next",
                systemImageName: "minus.circle",
                accessibilityHint: "Removes film from Up Next list"
            )
        } else {
            upNextButton.update(
                title: "Add to Up Next",
                systemImageName: "plus.circle",
                accessibilityHint: "Adds film to Up Next list"
            )
        }
    }

    private func updateWatchedButtonUI() {
        if isWatched {
            watchedButton.update(
                title: "Remove from Watched",
                systemImageName: "tv.slash",
                accessibilityHint: "Removes film from Watched list"
            )
        } else {
            watchedButton.update(
                title: "Add to Watched",
                systemImageName: "tv",
                accessibilityHint: "Adds film to Watched list"
            )
        }
    }
    
    // MARK: - Buttons Actions
    private func setupButtonActions() {
        upNextButton.addAction(UIAction { [weak self] _ in
            self?.handleQueueToggle(queue: .upNext)
        }, for: .touchUpInside)
        
        watchedButton.addAction(UIAction { [weak self] _ in
            self?.handleQueueToggle(queue: .watched)
        }, for: .touchUpInside)
    }
    
    private func handleQueueToggle(queue: FilmQueue) {
        guard case .content(let displayModel, _) = filmDetailViewModel.currentState else { return }
        let isActive = (queue == .upNext) ? isUpNext : isWatched
        let action: QueueAction = isActive ? .remove : .add
        let tappedButton = (queue == .upNext) ? upNextButton : watchedButton
        setButtonEnabled(false, button: tappedButton)
        Task {
            await filmDetailViewModel.updateStatus(for: displayModel.film, queue: queue, action: action)
        }
    }

    private func setButtonEnabled(_ enabled: Bool, button: FFButton) {
        if button == upNextButton {
            upNextButton.isEnabled = enabled
        } else {
            watchedButton.isEnabled = enabled
        }
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            movieBanner.topAnchor.constraint(equalTo: contentView.topAnchor),
            movieBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            movieBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: movieBanner.bottomAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            originalTitlesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            originalTitlesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            originalTitlesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            releaseDateAndRunningTimeLabel.topAnchor.constraint(equalTo: originalTitlesLabel.bottomAnchor, constant: padding),
            releaseDateAndRunningTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            releaseDateAndRunningTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            rottenTomatoesScoreLabel.topAnchor.constraint(equalTo: releaseDateAndRunningTimeLabel.bottomAnchor, constant: padding),
            rottenTomatoesScoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rottenTomatoesScoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            synopsisHeaderLabel.topAnchor.constraint(equalTo: rottenTomatoesScoreLabel.bottomAnchor, constant: padding),
            synopsisHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            synopsisHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            synopsisLabel.topAnchor.constraint(equalTo: synopsisHeaderLabel.bottomAnchor, constant: 8),
            synopsisLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            synopsisLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            creditsContainer.topAnchor.constraint(equalTo: synopsisLabel.bottomAnchor, constant: padding),
            creditsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            creditsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            buttonsContainer.topAnchor.constraint(equalTo: creditsContainer.bottomAnchor, constant: padding),
            buttonsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            buttonsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            buttonsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
        ])
    }
}

// MARK: - Film Detail View Model Delegate
extension ExploreDetailVC: FilmDetailViewModelDelegate {
    func didUpdateFilmDetails() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    func didUpdateWithEmptyState() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    func didUpdateUpNextStatus(isUpNext: Bool) {
        self.isUpNext = isUpNext
        setButtonEnabled(true, button: upNextButton)
    }
    
    func didUpdateWatchedStatus(isWatched: Bool) {
        self.isWatched = isWatched
        setButtonEnabled(true, button: watchedButton)
    }
    
    func didReceiveError() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
}

// MARK: - Preview
#Preview("Explore Detail") {
    let imageLoader = APIClientImageLoader(cacheManager: CacheManager())
    let testPersistenceController = try! PersistenceController(inMemory: true)
    let filmQueueService = FilmQueueService(context: testPersistenceController.viewContext)
    let vm = FilmDetailViewModel(film: Film.sample[0], imageLoader: imageLoader, filmQueueService: filmQueueService)
    let vc = ExploreDetailVC(filmDetailViewModel: vm)
    vc
}
