//
//  LibraryAlbumsViewController.swift
//  Spotify
//
//  Created by jake on 3/10/23.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {

    var albums: [Album] = []
    
    private let noAlbumsView = ActionLabelView()
    
    private var albumsObserver: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultsSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(noAlbumsView)
        noAlbumsView.configure(with: ActionLabelViewModel(text: "No albums", actionTitle: "Browse"))
        noAlbumsView.delegate = self
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        albumsObserver = NotificationCenter.default.addObserver(forName: .albumSavedNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchData()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        noAlbumsView.frame = CGRect(x: view.width+(view.width-150)/2, y: (view.height-150)/2, width: 150, height: 150)
        noAlbumsView.center = view.center
        
        tableView.frame = view.bounds
    }
    
    private func refreshUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            noAlbumsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func fetchData() {
        albums.removeAll()
        APIService.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.refreshUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
}

extension LibraryAlbumsViewController: ActionalLabelViewDelegate {
    func actionLabelViewDidTapButton() {
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultsSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultsSubtitleTableViewCellViewModel(title: album.name, description: album.artists.first?.name ?? "-", imageUrl: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsService.shared.vibrateSelect()
        
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        let albumVc = AlbumViewController(album: album)
        albumVc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(albumVc, animated: true)
    }
}
