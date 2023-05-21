//
//  ProfileViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var profileItems: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        getProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds 
    }
    
    private func getProfile() {
        APIService.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userProfile):
                    self?.update(with: userProfile)
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.failedGettingProfile()
                }
            }
        }
    }
    
    private func update(with model: UserProfile) {
        tableView.isHidden = false
        
        profileItems.append("Full Name: \(model.displayName)")
        profileItems.append("Email address: \(model.email)")
        profileItems.append("Plan: \(model.product)")
        
        createTableHeader(with: model.images.first?.url)
        
        tableView.reloadData()
    }
    
    private func createTableHeader(with string: String?) {
        guard let urlString = string, let url = URL(string: urlString) else {
            return
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        
        let imageSize: CGFloat = headerView.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFit
        imageView.sd_setImage(with: url, completed: nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        
        headerView.addSubview(imageView)
        tableView.tableHeaderView = headerView
    }
    
    private func failedGettingProfile() {
        let label = UILabel()
        label.text = "Failed to get profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = profileItems[indexPath.row]
        return cell
    }
}
