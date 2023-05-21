//
//  PlayerViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBack()
    func didSlideVolumeSlider(_ value: Float)
}

class PlayerViewController: UIViewController {

    weak var datasource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(artworkImageView)
        view.addSubview(controlsView)
        
        controlsView.delegate = self
        
        configureBarButtons()
        configureDatasource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        artworkImageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        controlsView.frame = CGRect(
            x: 10,
            y: artworkImageView.bottom+10,
            width: view.width-20,
            height: view.height-artworkImageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15)
    }
    
    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    private func configureDatasource() {
        artworkImageView.sd_setImage(with: datasource?.imageUrl, completed: nil)
        controlsView.configure(with: PlayerControlsViewModel(title: datasource?.songName, subtitle: datasource?.subtitle))
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAction() {
        // TODO
    }
    
    func refresh() {
        configureDatasource()
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideVolumeSlider volume: Float) {
        delegate?.didSlideVolumeSlider(volume)
    }
    
    func playerControlsViewDidTapPlayPause(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapForward(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func playerControlsViewDidTapBack(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBack()
    }
}
