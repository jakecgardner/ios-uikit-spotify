//
//  SearchResultsSubtitleTableViewCell.swift
//  Spotify
//
//  Created by jake on 3/8/23.
//

import UIKit
import SDWebImage

class SearchResultsSubtitleTableViewCell: UITableViewCell {
    static let identifier = "SearchResultsSubtitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height - 10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        
        label.frame = CGRect(x: iconImageView.right+10, y: 0, width: contentView.width-iconImageView.right-15, height: contentView.height / 2)
        subtitle.frame = CGRect(x: iconImageView.right+10, y: label.bottom, width: contentView.width-iconImageView.right-15, height: contentView.height / 2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        subtitle.text = nil
    }
    
    func configure(with viewModel: SearchResultsSubtitleTableViewCellViewModel) {
        label.text = viewModel.title
        subtitle.text = viewModel.description
        iconImageView.sd_setImage(with: viewModel.imageUrl, placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
}
