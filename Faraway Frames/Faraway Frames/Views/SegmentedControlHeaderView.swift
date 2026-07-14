//
//  SegmentedControlHeaderView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 13/07/2026.
//

import UIKit

final class SegmentedControlHeaderView: UICollectionReusableView {
    static let reuseID = "SegmentedHeaderView"
    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Up Next", "Watched"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
