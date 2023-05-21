//
//  LibraryToggleView.swift
//  Spotify
//
//  Created by jake on 3/10/23.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func didTapPlaylists()
    func didTapAlbums()
}

class LibraryToggleView: UIView {
    
    enum State {
        case playlist
        case album
    }
    
    var state: State = .playlist
    
    weak var delegate: LibraryToggleViewDelegate?
    
    private let playlistsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(playlistsButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        
        playlistsButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playlistsButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        albumsButton.frame = CGRect(x: playlistsButton.right, y: 0, width: 100, height: 50)
        
        layoutIndicator()
    }
    
    @objc private func didTapPlaylists() {
        update(for: .playlist)
        delegate?.didTapPlaylists()
    }
    
    @objc private func didTapAlbums() {
        update(for: .album)
        delegate?.didTapAlbums()
    }
    
    private func layoutIndicator() {
        switch state {
        case .playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistsButton.bottom, width: playlistsButton.width, height: 3)
        case .album:
            indicatorView.frame = CGRect(x: 100, y: playlistsButton.bottom, width: playlistsButton.width, height: 3)
        }
    }
    
    func update(for state: State) {
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
}
