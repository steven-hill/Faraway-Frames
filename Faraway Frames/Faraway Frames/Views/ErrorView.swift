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
        label.font = .preferredFont(forTextStyle: .subheadline)
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
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "ErrorView_Secondary_Label"
        return label
    }()
    
    let retryButton: UIButton = {
        var configuration = UIButton.Configuration.prominentGlass()
        configuration.title = "Retry"
        configuration.cornerStyle = .capsule
        configuration.background.backgroundColor = .systemGray6
        
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
    init(error: Error) {
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
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(secondaryLabel)
        stackView.addArrangedSubview(retryButton)
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
