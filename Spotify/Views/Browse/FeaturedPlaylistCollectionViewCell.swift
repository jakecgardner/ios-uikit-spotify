//
//  FeaturedPlaylistCollectionViewCell.swift
//  Spotify
//
//  Created by jake on 2/28/23.
//

import UIKit

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        contentView.addSubview(playlistImageView)
        
        NSLayoutConstraint.activate([
            playlistImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            playlistImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            playlistImageView.heightAnchor.constraint(equalToConstant: contentView.height),
            playlistImageView.widthAnchor.constraint(equalToConstant: contentView.height),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistImageView.image = nil
    }
    
    public func configure(with viewModel: FeaturedPlaylistViewModel) {
        playlistImageView.sd_setImage(with: viewModel.artwork, completed: nil)
    }
}
