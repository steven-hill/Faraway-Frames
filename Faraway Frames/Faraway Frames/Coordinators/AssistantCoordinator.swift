//
//  AssistantCoordinator.swift
//  Faraway Frames
//
//  Created by Steven Hill on 19/03/2026.
//

import UIKit

final class AssistantCoordinator: Coordinator {
    let assistantVC: UIViewController
    var navigationController = UINavigationController()
    
    init(assistantVC: UIViewController = AssistantVC()) {
        self.assistantVC = assistantVC
    }
    
    func start() {
        navigationController = UINavigationController(rootViewController: assistantVC)
    }
}
