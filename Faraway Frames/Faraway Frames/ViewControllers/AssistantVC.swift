//
//  AssistantVC.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/03/2026.
//

import UIKit

final class AssistantVC: UIViewController {
    
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
            action: #selector(closeTapped))
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
    AssistantVC()
}
