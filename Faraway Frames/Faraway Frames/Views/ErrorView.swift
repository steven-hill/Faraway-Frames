//
//  ErrorView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 01/08/2026.
//

import UIKit

final class ErrorView: UIView {
    
    // MARK: - Layout constant
    private enum Layout {
        static let stackViewHorizontalSpacing: CGFloat = 32
        static let iconImageViewSize: CGFloat = 50
    }
    
    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = SFSymbols.exclamationMarkTriangle
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "ErrorView_Icon_Image"
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Error loading films"
        label.accessibilityIdentifier = "ErrorView_Title_Label"
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "ErrorView_Secondary_Label"
        return label
    }()
    
    let retryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Retry"
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.baseForegroundColor = .label
        configuration.background.cornerRadius = 10
        configuration.titleAlignment = .center
        
        let button = UIButton(configuration: configuration)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "ErrorView_Retry_Button"
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialiser
    init(error: APIError) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.secondaryLabel.text = error.localizedDescription
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
        stackView.addArrangedSubview(retryButton)
        
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
