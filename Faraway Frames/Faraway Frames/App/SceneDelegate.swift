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
        setNetworkDependencies(with: window)
        mainCoordinator?.start()
        self.window = window
    }
    
    private func setNetworkDependencies(with window: UIWindow) {
        typealias Dependencies = FilmsListServicing & ImageLoading & PersistentContainerProtocol
        let dependencies: Dependencies
        
        if ProcessInfo.processInfo.isUITesting {
            UIView.setAnimationsEnabled(false)
            dependencies = MockDependencies()
        } else {
            dependencies = AppDependencyContainer()
        }
        mainCoordinator = MainCoordinator(window: window, dependencies: dependencies)
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
