//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify
//
//  Created by jake on 3/6/23.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        NSLayoutConstraint.activate([
            trackImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            trackImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            trackImageView.heightAnchor.constraint(equalToConstant: contentView.height),
            trackImageView.widthAnchor.constraint(equalToConstant: contentView.height),
            trackNameLabel.leftAnchor.constraint(equalTo: trackImageView.rightAnchor, constant: 4),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            trackNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            artistNameLabel.leftAnchor.constraint(equalTo: trackImageView.rightAnchor, constant: 4),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor),
            artistNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    public func configure(with viewModel: RecommendedTrackViewModel) {
        trackImageView.sd_setImage(with: viewModel.artwork, completed: nil)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
