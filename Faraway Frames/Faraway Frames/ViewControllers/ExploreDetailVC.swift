//
//  ExploreDetailViewController.swift
//  Faraway Frames
//
//  Created by Steven Hill on 09/01/2026.
//

import UIKit

final class ExploreDetailVC: UIViewController {
    
    // MARK: - Properties
    let filmDetailViewModel: FilmDetailViewModel
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
        movieBanner.isAccessibilityElement = true
        movieBanner.accessibilityTraits = .image
        return movieBanner
    }()
    
    private let titleLabel = FFLabel(font: .preferredFont(forTextStyle: .extraLargeTitle2), textColor: .label, accessibilityIdentifer: "ExploreDetailVC_TitleLabel")

    private let originalTitlesLabel = FFLabel(font: .preferredFont(forTextStyle: .title2), textColor: .secondaryLabel, accessibilityIdentifer: "ExploreDetailVC_OriginalTitlesLabel")

    private let releaseDateAndRunningTimeLabel = FFLabel(font: .preferredFont(forTextStyle: .title2), textColor: .secondaryLabel, accessibilityIdentifer: "ExploreDetailVC_ReleaseDateAndRunningTimeLabel")

    private let rottenTomatoesScoreLabel = FFLabel(font: .preferredFont(forTextStyle: .title2), textColor: nil, accessibilityIdentifer: "ExploreDetailVC_RottenTomatoesScoreLabel")
    
    private let synopsisHeaderLabel = FFLabel(font: .preferredFont(forTextStyle: .headline), textColor: .label, accessibilityIdentifer: "ExploreDetailVC_SynopsisHeaderLabel", accessibilityTraits: .header)
    
    private let synopsisLabel = FFLabel(font: .preferredFont(forTextStyle: .body), textColor: .label, accessibilityIdentifer: "ExploreDetailVC_SynopsisLabel")
    
    private let creditsContainer: UIStackView = {
        let creditsContainer = UIStackView()
        creditsContainer.spacing = 20
        creditsContainer.translatesAutoresizingMaskIntoConstraints = false
        creditsContainer.accessibilityIdentifier = "ExploreDetailVC_CreditsContainer"
        return creditsContainer
    }()
    
    private let addToUpNextButton = FFButton(title: "Add To Up Next", accessibilityIdentifier: "ExploreDetailVC_AddToUpNextButton", accessibilityHint: "Double tap to add this film to your Up Next list")

    private let markAsWatchedButton = FFButton(title: "Mark As Watched", accessibilityIdentifier: "ExploreDetailVC_MarkAsWatchedButton", accessibilityHint: "Double tap to mark this film as watched")

    private let moreLikeThisButton = FFButton(title: "More Like This", accessibilityIdentifier: "ExploreDetailVC_MoreLikeThisButton", accessibilityHint: "Double tap to discover more films like this")
    
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
        case .content(let film, let image):
            config = nil
            createContent(film: film, image: image)
        }
        self.contentUnavailableConfiguration = config
    }
    
    private func createContent(film: Film, image: UIImage?) {
        movieBanner.image = image
        movieBanner.contentMode = (movieBanner.image == SFSymbols.movieClapper) ? .scaleAspectFit : .scaleAspectFill
        movieBanner.accessibilityLabel = NSLocalizedString("Movie poster", comment: "")
        titleLabel.text = film.title
        originalTitlesLabel.text = "\(film.originalTitle) \n\(film.originalTitleRomanised)"
        releaseDateAndRunningTimeLabel.text = "\(film.releaseDate) • \(film.runningTime) mins"
        synopsisHeaderLabel.text = NSLocalizedString("Synopsis", comment: "")
        synopsisLabel.text = film.description
        rottenTomatoesScoreLabel.attributedText = setScoreText(for: film.rottenTomatoesScore)
        creditsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let directorView = createCreditView(name: film.director, role: "Director")
        let producerView = createCreditView(name: film.producer, role: "Producer")
        creditsContainer.addArrangedSubview(directorView)
        creditsContainer.addArrangedSubview(producerView)
        buttonsContainer.addArrangedSubview(addToUpNextButton)
        buttonsContainer.addArrangedSubview(markAsWatchedButton)
        buttonsContainer.addArrangedSubview(moreLikeThisButton)
    }
    
    private func createEmptyState() -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = SFSymbols.movieClapper
        config.text = "No Film Selected"
        config.secondaryText = "Select a film from the list for more details."
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
    
    private func setScoreText(for string: String) -> NSMutableAttributedString {
        let fullText = "Rotten Tomatoes \(string)%"
        let attributedString = NSMutableAttributedString(string: fullText)
        let rtRange = NSRange(location: 0, length: 16)
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: rtRange)
        let scoreRange = NSRange(location: 16, length: fullText.count - 16)
        attributedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: scoreRange)
        return attributedString
    }
    
    private func createCreditView(name: String, role: String) -> UIStackView {
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontForContentSizeCategory = true
        
        let roleLabel = UILabel()
        roleLabel.text = role
        roleLabel.font = .preferredFont(forTextStyle: .subheadline)
        roleLabel.textColor = .secondaryLabel
        roleLabel.numberOfLines = 0
        roleLabel.adjustsFontForContentSizeCategory = true
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    private func setupScrollView() {
        scrollView.bouncesVertically = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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
}

// MARK: - Preview
#Preview("Explore Detail") {
    let imageLoader = APIClientImageLoader(cacheManager: CacheManager())
    let vm = FilmDetailViewModel(film: Film.sample[0], imageLoader: imageLoader)
    let vc = ExploreDetailVC(filmDetailViewModel: vm)
    vc
}
