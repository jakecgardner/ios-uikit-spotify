//
//  NewReleaseCollectionViewCell.swift
//  Spotify
//
//  Created by jake on 2/28/23.
//

import UIKit

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        contentView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            albumCoverImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            albumCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            albumCoverImageView.widthAnchor.constraint(equalToConstant: contentView.height),
            albumCoverImageView.heightAnchor.constraint(equalToConstant: contentView.height),
            albumNameLabel.leftAnchor.constraint(equalTo: albumCoverImageView.rightAnchor, constant: 4),
            albumNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            albumNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            artistNameLabel.leftAnchor.constraint(equalTo: albumCoverImageView.rightAnchor, constant: 4),
            artistNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 4),
            numberOfTracksLabel.leftAnchor.constraint(equalTo: albumCoverImageView.rightAnchor, constant: 4),
            numberOfTracksLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            numberOfTracksLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4-numberOfTracksLabel.height),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    public func configure(with viewModel: NewReleaseViewModel) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkUrl, completed: nil)
    }
}
