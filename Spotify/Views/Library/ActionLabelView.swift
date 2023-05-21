//
//  ActionLabelView.swift
//  Spotify
//
//  Created by jake on 3/13/23.
//

import UIKit

protocol ActionalLabelViewDelegate: AnyObject {
    func actionLabelViewDidTapButton()
}

class ActionLabelView: UIView {
    
    weak var delegate: ActionalLabelViewDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        isHidden = true
        
        addSubview(label)
        addSubview(button)
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.frame = CGRect(x: 0, y: height-40, width: width, height: 40)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height-40)
    }
    
    @objc func didTapButton() {
        delegate?.actionLabelViewDidTapButton()
    }
    
    func configure(with viewModel: ActionLabelViewModel) {
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
}
