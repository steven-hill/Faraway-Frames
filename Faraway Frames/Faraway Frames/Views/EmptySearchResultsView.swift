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
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialiser
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Configuration
    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(secondaryLabel)
        
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.stackViewHorizontalSpacing),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.stackViewHorizontalSpacing),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconImageViewSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconImageViewSize)
        ])
    }
}
