//
//  CategoryCollectionViewCell.swift
//  Spotify
//
//  Created by jake on 3/7/23.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    private let colors: [UIColor] = [
        .systemPink,
        .systemGreen,
        .systemCyan,
        .systemPurple,
        .systemOrange,
        .systemBlue,
        .systemMint
    ]
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 50))
        )
        return imageView
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(genreLabel)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        genreLabel.frame = CGRect(
            x: 10,
            y: contentView.height / 2,
            width: contentView.width - 20,
            height: contentView.height / 2)
        
        imageView.frame = CGRect(x: contentView.width / 2, y: 10, width: contentView.width / 2, height: contentView.height / 2)
    }
    
    override func prepareForReuse() {
        imageView.image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 50))
        )
        genreLabel.text = nil
    }
    
    func configure(with viewModel: CategoryCollectionCellViewModel) {
        genreLabel.text = viewModel.name
        imageView.sd_setImage(with: viewModel.artwork, completed: nil)
        contentView.backgroundColor = colors.randomElement()
    }
}
