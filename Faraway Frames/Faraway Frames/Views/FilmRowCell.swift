//
//  FilmRowCell.swift
//  Faraway Frames
//
//  Created by Steven Hill on 24/07/2026.
//

import UIKit

final class FilmRowCell: UICollectionViewListCell {
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.accessibilityIdentifier = "Film_Cell_Poster"
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.accessibilityIdentifier = "Film_Cell_Title"
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Constraints References
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        registerTraits()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        containerStackView.addArrangedSubview(posterImageView)
        containerStackView.addArrangedSubview(titleLabel)
        contentView.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        imageWidthConstraint = posterImageView.widthAnchor.constraint(equalToConstant: 60)
        imageHeightConstraint = posterImageView.heightAnchor.constraint(equalToConstant: 90)
        imageHeightConstraint?.priority = .init(999)
        
        NSLayoutConstraint.activate([
            imageWidthConstraint!,
            imageHeightConstraint!
        ])
        
        updateLayoutForTraits(traitCollection)
    }
    
    // MARK: - Trait Registration
    private func registerTraits() {
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _) in
            self.updateLayoutForTraits(self.traitCollection)
        }
    }
    
    // MARK: - Layout Customisation
    private func updateLayoutForTraits(_ traits: UITraitCollection) {
        let isAccessibilitySize = traits.preferredContentSizeCategory.isAccessibilityCategory
        
        if isAccessibilitySize {
            containerStackView.axis = .vertical
            containerStackView.alignment = .leading
            containerStackView.spacing = 8
        } else {
            containerStackView.axis = .horizontal
            containerStackView.alignment = .center
            containerStackView.spacing = 12
        }
        
        let bodyMetrics = UIFontMetrics(forTextStyle: .body)
        let scaledWidth = bodyMetrics.scaledValue(for: 60, compatibleWith: traits)
        let scaledHeight = bodyMetrics.scaledValue(for: 90, compatibleWith: traits)
        let scaledCornerRadius = bodyMetrics.scaledValue(for: 10, compatibleWith: traits)
        
        imageWidthConstraint?.constant = scaledWidth
        imageHeightConstraint?.constant = scaledHeight
        posterImageView.layer.cornerRadius = scaledCornerRadius
    }
    
    // MARK: - Configuration
    func configure(with title: String, image: UIImage?) {
        titleLabel.text = title
        posterImageView.image = image ?? UIImage(systemName: "photo")
        accessories = [.disclosureIndicator()]
        isAccessibilityElement = true
        accessibilityLabel = title
    }
    
    // MARK: - Reuse Optimisation
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        posterImageView.image = nil
        accessibilityLabel = nil
        isAccessibilityElement = false
        accessories = []
    }
}
