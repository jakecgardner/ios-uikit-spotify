//
//  SettingsViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var sections: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        configure()
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func configure() {
        sections.append(.init(title: "Profile", options: [Option(title: "View your profile", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
        })]))
        
        sections.append(.init(title: "Account", options: [Option(title: "Sign out", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOut()
            }
        })]))
    }
    
    private func viewProfile() {
        let profileVc = ProfileViewController()
        profileVc.title = "Profile"
        profileVc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(profileVc, animated: true)
    }
    
    private func signOut() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthService.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        let navigationVC = UINavigationController(rootViewController: WelcomeViewController())
                        navigationVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navigationVC.navigationBar.prefersLargeTitles = true
                        navigationVC.modalPresentationStyle = .fullScreen
                        self?.present(navigationVC, animated: true) {
                            self?.navigationController?.popToRootViewController(animated: false)
                        }
                    }
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let option = sections[indexPath.section].options[indexPath.row]
        cell.textLabel?.text = option.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = sections[indexPath.section].options[indexPath.row]
        option.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.title
    }
}
