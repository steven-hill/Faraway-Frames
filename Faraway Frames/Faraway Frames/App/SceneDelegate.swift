//
//  SceneDelegate.swift
//  Faraway Frames
//
//  Created by Steven Hill on 05/01/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var mainCoordinator: MainCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        setUpDependencies(with: window)
        mainCoordinator?.start()
        self.window = window
    }
    
    private func setUpDependencies(with window: UIWindow) {
        typealias Dependencies = FilmsListServicing & ImageLoading & PersistentStoring & AccessibilityServicing
        let dependencies: Dependencies
        
        if ProcessInfo.processInfo.isUITesting {
            UIView.setAnimationsEnabled(false)
            dependencies = MockDependencies()
        } else {
            dependencies = AppDependencyContainer()
        }
        
        do {
            let persistenceController = try dependencies.makePersistenceController()
            mainCoordinator = MainCoordinator(window: window, dependencies: dependencies, persistenceController: persistenceController)
        } catch {
            // TODO: - Replace with View Controller showing an error message.
            fatalError()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
