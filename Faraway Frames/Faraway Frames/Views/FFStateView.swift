//
//  FFStateView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 02/08/2026.
//

import UIKit

final class FFStateView: UIView {
    
    // MARK: - Layout Constants
    private enum Layout {
        static let stackViewHorizontalSpacing: CGFloat = 32
        static let iconImageViewSize: CGFloat = 50
        static let maxButtonWidth: CGFloat = 120
    }
    
    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let retryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.baseForegroundColor = .label
        configuration.background.cornerRadius = 10
        configuration.titleAlignment = .center
        
        let button = UIButton(configuration: configuration)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialisation
    init(
        image: UIImage?,
        imageTintColor: UIColor,
        title: String,
        secondaryText: String?,
        buttonTitle: String? = nil,
        accessibilityIdentifier: String
    ) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.iconImageView.image = image
        self.iconImageView.tintColor = imageTintColor
        self.titleLabel.text = title
        self.secondaryLabel.text = secondaryText
        
        if let buttonTitle = buttonTitle {
            self.retryButton.configuration?.title = buttonTitle
            self.retryButton.isHidden = false
        }
        
        self.accessibilityIdentifier = "\(accessibilityIdentifier)"
        self.iconImageView.accessibilityIdentifier = "\(accessibilityIdentifier)_Icon_Image"
        self.titleLabel.accessibilityIdentifier = "\(accessibilityIdentifier)_Title_Label"
        self.secondaryLabel.accessibilityIdentifier = "\(accessibilityIdentifier)_Secondary_Label"
        self.retryButton.accessibilityIdentifier = "\(accessibilityIdentifier)_Retry_Button"
        
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
        
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(retryButton)
        stackView.addArrangedSubview(buttonContainer)
        
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
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconImageViewSize),
            
            retryButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            retryButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            retryButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: Layout.maxButtonWidth)
        ])
    }
}
