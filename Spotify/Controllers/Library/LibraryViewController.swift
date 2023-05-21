//
//  LibraryViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

class LibraryViewController: UIViewController {
    
    private let playlistsVc = LibraryPlaylistViewController()
    private let albumsVc = LibraryAlbumsViewController()
    
    private let toggleView = LibraryToggleView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        view.addSubview(toggleView)
        
        toggleView.delegate = self
        scrollView.delegate = self
        
        scrollView.contentSize = CGSize(width: view.width*2, height: view.height)
        
        addScrollChildren()
        updateBarButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.width, height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55)
        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
    }
    
    func addScrollChildren() {
        addChild(playlistsVc)
        scrollView.addSubview(playlistsVc.view)
        playlistsVc.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistsVc.didMove(toParent: self)
        
        addChild(albumsVc)
        scrollView.addSubview(albumsVc.view)
        albumsVc.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVc.didMove(toParent: self)
    }
    
    private func updateBarButtons() {
        switch toggleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapAdd() {
        playlistsVc.showCreatePlaylistAlert()
    }
}

extension LibraryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-100) {
            toggleView.update(for: .album)
        } else {
            toggleView.update(for: .playlist)
        }
        updateBarButtons()
    }
}

extension LibraryViewController: LibraryToggleViewDelegate {
    func didTapPlaylists() {
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }
    
    func didTapAlbums() {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
}
