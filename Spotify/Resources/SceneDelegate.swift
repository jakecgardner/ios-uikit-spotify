//
//  SceneDelegate.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if AuthService.shared.isSignedIn {
            window?.rootViewController = TabBarViewController()
        } else {
            let navigationVC = UINavigationController(rootViewController: WelcomeViewController())
            navigationVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            navigationVC.navigationBar.prefersLargeTitles = true
            window?.rootViewController = navigationVC
        }
        
        window?.makeKeyAndVisible()
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

