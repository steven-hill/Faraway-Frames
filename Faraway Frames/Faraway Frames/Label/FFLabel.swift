//
//  FFLabel.swift
//  Faraway Frames
//
//  Created by Steven Hill on 22/02/2026.
//

import UIKit

final class FFLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(font: UIFont, textColor: UIColor?, accessibilityIdentifer: String? = nil) {
        self.init(frame: .zero)
        self.font = font
        self.textColor = textColor
        self.accessibilityIdentifier = accessibilityIdentifer
    }
    
    private func configure() {
        numberOfLines = 0
        textAlignment = .natural
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.9
        translatesAutoresizingMaskIntoConstraints = false
    }
}
