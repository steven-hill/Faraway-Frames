//
//  FFButton.swift
//  Faraway Frames
//
//  Created by Steven Hill on 10/04/2026.
//

import UIKit

final class FFButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, accessibilityIdentifier: String, accessibilityHint: String) {
        self.init(frame: .zero)
        set(title: title, accessibilityIdentifier: accessibilityIdentifier, accessibilityHint: accessibilityHint)
    }
    
    private func configure() {
        configuration = .filled()
        configuration?.baseBackgroundColor = .secondarySystemBackground
        configuration?.baseForegroundColor = .label
        configuration?.background.cornerRadius = 10
        configuration?.titleLineBreakMode = .byWordWrapping
        configuration?.titleAlignment = .center
        configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .body)
            return outgoing
        }
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
    
    private func set(title: String, accessibilityIdentifier: String, accessibilityHint: String) {
        configuration?.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityHint = accessibilityHint
    }
}
