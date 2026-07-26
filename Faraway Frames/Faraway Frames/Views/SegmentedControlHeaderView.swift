//
//  SegmentedControlHeaderView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 13/07/2026.
//

import UIKit

final class SegmentedControlHeaderView: UICollectionReusableView {
    
    // MARK: - Layout Constant
    private enum Layout {
        static let offset: CGFloat = 8
    }
    
    // MARK: - Segmented Control
    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Up Next", "Watched"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews Method
    private func setupSubviews() {
        addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor,
                                                  constant: Layout.offset),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: Layout.offset),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                       constant: -Layout.offset),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                     constant: -Layout.offset)
        ])
    }
}
