//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by jake on 3/6/23.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubview(playlistImageView)
        addSubview(nameLabel)
        addSubview(creatorLabel)
        addSubview(descriptionLabel)
        addSubview(playAllButton)
        
        NSLayoutConstraint.activate([
            playlistImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            playlistImageView.topAnchor.constraint(equalTo: self.topAnchor),
            playlistImageView.widthAnchor.constraint(equalToConstant: self.width),
            playlistImageView.heightAnchor.constraint(equalToConstant: self.width),
            nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4),
            nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4),
            nameLabel.topAnchor.constraint(equalTo: playlistImageView.bottomAnchor, constant: 4),
            creatorLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4),
            creatorLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4),
            creatorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4),
            descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4),
            descriptionLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 4),
            playAllButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            playAllButton.bottomAnchor.constraint(equalTo: playlistImageView.bottomAnchor, constant: -20),
            playAllButton.widthAnchor.constraint(equalToConstant: 60),
            playAllButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    @objc private func didTapPlayAll() {
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        descriptionLabel.text = nil
        creatorLabel.text = nil
        playlistImageView.image = nil
    }
    
    func configure(with viewModel: PlaylistHeaderViewModel) {
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        creatorLabel.text = viewModel.creatorName
        playlistImageView.sd_setImage(with: viewModel.artwork, completed: nil)
    }
}
