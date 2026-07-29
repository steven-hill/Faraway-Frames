//
//  FilmGridCell.swift
//  Faraway Frames
//
//  Created by Steven Hill on 10/07/2026.
//

import UIKit

final class FilmGridCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "Film_Grid_Cell_Poster"
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "Film_Grid_Cell_Title"
        label.accessibilityTraits = .button
        return label
    }()
    
    // MARK: - Initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        
        let aspectRatioConstraint = posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.3)
        aspectRatioConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            aspectRatioConstraint,
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration Methods
    func configure(with film: Film) {
        titleLabel.text = film.title
    }
    
    func updateImage(_ image: UIImage) {
        UIView.transition(with: posterImageView, duration: 0.2, options: .transitionCrossDissolve) {
            self.posterImageView.image = image
        }
    }
    
    // MARK: - Prepare For Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
    }
}

// MARK: - Extension
extension FilmGridCell {
    /// Property accessible only for purposes of unit testing.
    var currentDisplayedImage: UIImage? {
        return posterImageView.image
    }
}
