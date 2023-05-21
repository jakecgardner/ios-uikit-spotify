//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

class WelcomeViewController: UIViewController {

    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign in with Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome"
        view.backgroundColor = .systemGreen
        
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 20, y: view.height-view.safeAreaInsets.bottom-50, width: view.width-40, height: 50)
    }
    
    @objc func didTapSignIn() {
        let authVc = AuthViewController()
        authVc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        authVc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(authVc, animated: true)
    }
    
    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oops", message: "Something went wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        let tabBarVc = TabBarViewController()
        tabBarVc.modalPresentationStyle = .fullScreen
        present(tabBarVc, animated: true)
    }
}
