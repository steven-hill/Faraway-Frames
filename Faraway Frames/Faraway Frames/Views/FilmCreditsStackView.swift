//
//  FilmCreditsStackView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 23/05/2026.
//

import UIKit

final class FilmCreditsStackView: UIStackView {
    
    // MARK: - Configure Method
    func configure(withDirector director: String,
                   producer: String,
                   accessibilityLabelText: String) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        let directorView = createCreditView(name: director, role: "Director")
        let producerView = createCreditView(name: producer, role: "Producer")
        addArrangedSubview(directorView)
        addArrangedSubview(producerView)
        self.accessibilityLabel = accessibilityLabelText
    }
    
    // MARK: - Credit View Method
    private func createCreditView(name: String,
                                  role: String) -> UIView {
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
}
