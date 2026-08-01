//
//  EmptySearchResultsView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/08/2026.
//

import UIKit

final class EmptySearchResultsView: UIView {
    
    // MARK: - Layout constant
    private enum Layout {
        static let stackViewHorizontalSpacing: CGFloat = 32
        static let iconImageViewSize: CGFloat = 50
    }
    
    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "Empty_Search_Results_Icon_Image"
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No Results"
        label.accessibilityIdentifier = "Empty_Search_Results_Title_Label"
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Try a different search term."
        label.accessibilityIdentifier = "Empty_Search_Results_Secondary_Label"
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialiser
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        setupTraitObservations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            updateLayoutForTraits()
        }
    }
    
    // MARK: - Reactive Trait Updates
    private func setupTraitObservations() {
        registerForTraitChanges([
            UITraitVerticalSizeClass.self,
            UITraitPreferredContentSizeCategory.self
        ]) { (self: Self, previousTraitCollection: UITraitCollection) in
            self.updateLayoutForTraits()
        }
    }
    
    private func updateLayoutForTraits() {
        let isVerticallyCompact = traitCollection.verticalSizeClass == .compact
        let isAccessibilitySize = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if isVerticallyCompact && isAccessibilitySize {
            iconImageView.isHidden = true
            stackView.spacing = 6
        } else {
            iconImageView.isHidden = false
            stackView.spacing = 12
        }
    }
    
    // MARK: - Layout Configuration
    private func setupLayout() {
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(secondaryLabel)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconImageViewSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconImageViewSize),
            
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Layout.stackViewHorizontalSpacing),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Layout.stackViewHorizontalSpacing)
        ])
    }
}
