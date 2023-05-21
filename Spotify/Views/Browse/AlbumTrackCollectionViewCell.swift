//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify
//
//  Created by jake on 3/6/23.
//

import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "album-track-cell"
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        NSLayoutConstraint.activate([
            trackNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            trackNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            artistNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor),
            artistNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    public func configure(with viewModel: AlbumTrackViewModel) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
