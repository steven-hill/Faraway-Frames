//
//  AssistantVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/03/2026.
//

import UIKit

final class AssistantVC: UIViewController {

    // MARK: - Property
    private let assistantViewModel: AssistantViewModel
    
    // MARK: - Initialisation
    init(assistantViewModel: AssistantViewModel) {
        self.assistantViewModel = assistantViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Assistant"
        setUpCloseButton()
    }
    
    private func setUpCloseButton() {
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.accessibilityIdentifier = "AssistantVC_CloseButton"
        closeButton.accessibilityLabel = "Return to film details"
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Preview
#Preview("AssistantVC") {
    AssistantVC(assistantViewModel: AssistantViewModel())
}
