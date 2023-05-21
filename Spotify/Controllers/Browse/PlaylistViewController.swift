//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

class PlaylistViewController: UIViewController {

    private let playlist: Playlist
    private var tracks: [Track] = []
    
    public var isOwner = false
    
    private var viewModels: [RecommendedTrackViewModel] = []
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
                
                let verticalGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(60.0)),
                    subitems: [item])
                
                let section = NSCollectionLayoutSection(group: verticalGroup)
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(500)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                ]
                return section
            })
        )
        
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        return collectionView
    }()
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        configureCollectionView()
        
        fetchData()
        
        addLongPressGesture()
    }
    
    private func addLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressTrack(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didLongPressTrack(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        let touchPoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
            return
        }
        let trackToRemove = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: trackToRemove.name, message: "Would you like to remove this track?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            guard let self = self else {
                return
            }
            APIService.shared.removeTrackFromPlaylist(track: trackToRemove, playlist: self.playlist) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self.tracks.remove(at: indexPath.row)
                        self.viewModels.remove(at: indexPath.row)
                        self.collectionView.reloadData()
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }))
        present(actionSheet, animated: true)
    }
    
    @objc private func didTapShare() {
        guard let url = URL(string: playlist.externalUrls["spotify"] ?? "") else {
            return
        }
        let vc = UIActivityViewController(
            activityItems: [
                url
            ],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.frame = view.bounds
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func fetchData() {
        APIService.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.tracks = response.tracks.items.compactMap({ $0.track })
                    self?.viewModels = response.tracks.items.compactMap({
                        RecommendedTrackViewModel(
                            name: $0.track.name,
                            artwork: URL(string: $0.track.album?.images.first?.url ?? "-"),
                            artistName: $0.track.artists.first?.name ?? "-"
                        )
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as?      PlaylistHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let headerViewModel = PlaylistHeaderViewModel(
            name: playlist.name,
            description: playlist.description,
            creatorName: playlist.owner.displayName,
            artwork: URL(string: playlist.images.first?.url ?? "")
        )
        header.delegate = self
        header.configure(with: headerViewModel)
        return header
    }
    
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
}
