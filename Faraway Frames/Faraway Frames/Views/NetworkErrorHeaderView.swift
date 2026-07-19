//
//  NetworkErrorReusableView.swift
//  Faraway Frames
//
//  Created by Steven Hill on 10/05/2026.
//

import UIKit

final class NetworkErrorHeaderView: UICollectionReusableView {    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.text = "Network error"
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.text = "Using archived data"
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.accessibilityIdentifier = "Network_Error_Header_View"
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            
            textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            textStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            textStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
