//
//  ViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleaseViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistViewModel])
    
    var title: String {
        switch self  {
        case .newReleases:
            return "New Releases"
        case .featuredPlaylists:
            return "Featured Playlists"
        }
    }
}

class HomeViewController: UIViewController {

    private var collectionView: UICollectionView!
    
    private var albums = [Album]()
    private var playlists = [Playlist]()
    private var tracks = [Track]()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections: [BrowseSectionType] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        
        configureCollectionView()
        configureSpinner()
        
        fetchData()
        
        addLongTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    // MARK: - UI Config
    
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: CGRect.zero,
            collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ in
                return self.createSectionLayout(section: sectionIndex)
            })
        view.addSubview(collectionView)
        collectionView?.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView?.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .systemBackground
    }
    
    private func configureSpinner() {
        view.addSubview(spinner)
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesResponse?
        var featuredPlaylists: FeaturedPlaylistResponse?
        
        APIService.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                newReleases = response
            case .failure(let error):
                print(error)
            }
        }
        
        APIService.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let response):
                featuredPlaylists = response
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) {
            guard let releases = newReleases?.albums.items, let playlists = featuredPlaylists?.playlists.items else {
                return
            }
            self.configureViewModels(newAlbums: releases, playlists: playlists)
        }
    }
    
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint), indexPath.section == 2 else {
            return
        }
        
        let track = tracks[indexPath.row]
        let actionSheet = UIAlertController(title: track.name, message: "Would you like to add this to a playlist?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let libraryVc = LibraryPlaylistViewController()
                libraryVc.selectionHandler = { playlist in
                    APIService.shared.addTrackToPlaylist(track: track, playlist: playlist) { result in
                        switch result {
                        case .success(_):
                            print("success")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                libraryVc.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: libraryVc), animated: true)
            }
        }))
        present(actionSheet, animated: true)
    }
    
    private func configureViewModels(newAlbums: [Album], playlists: [Playlist]) {
        DispatchQueue.main.async {
            self.albums = newAlbums
            self.playlists = playlists
            self.sections.append(
                .newReleases(viewModels: newAlbums.compactMap({ album in
                    NewReleaseViewModel(
                        name: album.name,
                        artworkUrl: URL(string: album.images.first?.url ?? ""),
                        numberOfTracks: album.totalTracks,
                        artistName: album.artists.first?.name ?? ""
                    )
                }))
            )
            self.sections.append(
                .featuredPlaylists(
                    viewModels: playlists.compactMap({ playlist in
                        FeaturedPlaylistViewModel(
                            name: playlist.name,
                            artwork: URL(string: playlist.images.first?.url ?? ""),
                            creatorName: playlist.owner.displayName
                        )
                    })
                )
            )
            self.collectionView?.reloadData()
        }
    }

    @objc func didTapSettings() {
        let settingsVc = SettingsViewController()
        settingsVc.title = "Settings"
        settingsVc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(settingsVc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else {
                fatalError()
            }
            let model = viewModels[indexPath.row]
            cell.configure(with: model)
            return cell
            
        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {
                fatalError()
            }
            let model = viewModels[indexPath.row]
            cell.configure(with: model)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let albums):
            return albums.count
        case .featuredPlaylists(let playlists):
            return playlists.count
        }
    }
    
    func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        switch section {
        case 0:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(150.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(450.0)),
                subitems: [item])
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(450.0)),
                subitems: [verticalGroup])
            
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 1:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(200.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200.0),
                    heightDimension: .absolute(400.0)),
                subitems: [item])
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200.0),
                    heightDimension: .absolute(400.0)),
                subitems: [verticalGroup])
            
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80.0)),
                subitems: [item])
            
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsService.shared.vibrateSelect()
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let type = sections[indexPath.section]
        switch type {
        case .newReleases:
            let album = albums[indexPath.row]
            let albumVc = AlbumViewController(album: album)
            albumVc.title = album.name
            albumVc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(albumVc, animated: true)
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let playlistVc = PlaylistViewController(playlist: playlist)
            playlistVc.title = playlist.name
            playlistVc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(playlistVc, animated: true)
        }
    }
}
