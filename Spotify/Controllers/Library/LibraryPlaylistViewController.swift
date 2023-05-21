//
//  LibraryPlaylistViewController.swift
//  Spotify
//
//  Created by jake on 3/10/23.
//

import UIKit

class LibraryPlaylistViewController: UIViewController {

    var playlists: [Playlist] = []
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    private let noPlaylistsView = ActionLabelView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultsSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(noPlaylistsView)
        noPlaylistsView.configure(with: ActionLabelViewModel(text: "No playlists", actionTitle: "Create"))
        noPlaylistsView.delegate = self
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        noPlaylistsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistsView.center = view.center
        
        tableView.frame = view.bounds
    }
    
    private func refreshUI() {
        if playlists.isEmpty {
            noPlaylistsView.isHidden = false
            tableView.isHidden = true
        } else {
            noPlaylistsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func fetchData() {
        APIService.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.refreshUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter playlist name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Playlist..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            APIService.shared.createPlaylist(with: text) { [weak self] result in
                switch result {
                case .success(_):
                    HapticsService.shared.vibrate(for: .success)
                    self?.fetchData()
                case .failure(_):
                    HapticsService.shared.vibrate(for: .error)
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
}

extension LibraryPlaylistViewController: ActionalLabelViewDelegate {
    func actionLabelViewDidTapButton() {
        showCreatePlaylistAlert()
    }
}

extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultsSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultsSubtitleTableViewCellViewModel(title: playlist.name, description: playlist.owner.displayName, imageUrl: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsService.shared.vibrateSelect()
        
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
         
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
        
        let playlistVc = PlaylistViewController(playlist: playlist)
        playlistVc.navigationItem.largeTitleDisplayMode = .never
        playlistVc.isOwner = true
        navigationController?.pushViewController(playlistVc, animated: true)
    }
}
