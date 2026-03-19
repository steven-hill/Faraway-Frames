//
//  AssistantCoordinator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/03/2026.
//

import UIKit

final class AssistantCoordinator: Coordinator {
    let assistantVC: UIViewController
    
    init(assistantVC: UIViewController = AssistantVC()) {
        self.assistantVC = assistantVC
    }
    
    func start() {
        createAssistantVC()
    }
    
    private func createAssistantVC() {
        let _ = UINavigationController(rootViewController: assistantVC)
    }
}
