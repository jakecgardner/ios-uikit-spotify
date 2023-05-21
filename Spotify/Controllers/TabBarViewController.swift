//
//  TabBarViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tab1 = HomeViewController()
        let tab2 = SearchViewController()
        let tab3 = LibraryViewController()
        
        tab1.title = "Browse"
        tab2.title = "Search"
        tab3.title = "Library"
        
        tab1.navigationItem.largeTitleDisplayMode = .always
        tab2.navigationItem.largeTitleDisplayMode = .always
        tab3.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: tab1)
        let nav2 = UINavigationController(rootViewController: tab2)
        let nav3 = UINavigationController(rootViewController: tab3)
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        
        setViewControllers([nav1, nav2, nav3], animated: false)
    }
}
