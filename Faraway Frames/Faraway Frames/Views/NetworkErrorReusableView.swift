//
//  NetworkErrorReusableView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 10/05/2026.
//

import UIKit

final class NetworkErrorReusableView: UICollectionReusableView {
    static let identifier = "NetworkErrorReusableView"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.text = "Network error\n Using archived data"
        label.accessibilityIdentifier = "Network_Error_Reusable_View"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(label)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
