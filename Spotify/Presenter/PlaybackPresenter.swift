//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by jake on 3/9/23.
//

import UIKit
import AVFoundation

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageUrl: URL? { get }
}

final class PlaybackPresenter {
    static let shared = PlaybackPresenter()
    
    private init() {}
    
    private var track: Track?
    private var tracks: [Track] = []
    
    private var player: AVPlayer?
    private var playerVc: PlayerViewController?
    
    private var queuePlayer: AVQueuePlayer?
    private var currentItemIndex = 0
    private var playerItems: [AVPlayerItem] = []
    
    var currentTrack: Track? {
        if !tracks.isEmpty {
            return tracks[currentItemIndex]
        }
        else if let track = track {
            return track
        }
        return nil
    }
    
    func startPlayback(
        from viewController: UIViewController,
        track: Track
    ) {
        guard let url = URL(string: track.previewUrl ?? "") else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        
        let vc = PlayerViewController()
        vc.title = track.name
        vc.datasource = self
        playerVc = vc
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
    }
    
    func startPlayback(
        from viewController: UIViewController,
        tracks: [Track]
    ) {
        self.tracks = tracks
        self.currentItemIndex = 0
        self.track = nil
        
        playerItems = tracks.compactMap({
            guard let url = URL(string: $0.previewUrl ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        })
        self.queuePlayer = AVQueuePlayer(items: playerItems)
        self.queuePlayer?.volume = 0.5
        self.queuePlayer?.play()
        
        let vc = PlayerViewController()
        vc.title = tracks.first?.name
        vc.datasource = self
        playerVc = vc
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageUrl: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didSlideVolumeSlider(_ value: Float) {
        
    }
    
    func didTapBack() {
        if tracks.isEmpty {
            player?.pause()
        }
        else if let player = queuePlayer {
            player.pause()
            player.removeAllItems()
            self.queuePlayer = AVQueuePlayer(items: playerItems)
            self.queuePlayer?.play()
        }
    }
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
        else if let player = queuePlayer {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            player?.pause()
        }
        else if let player = queuePlayer {
            if currentItemIndex >= playerItems.count - 1 {
                player.pause()
                currentItemIndex = 0
            } else {
                player.advanceToNextItem()
                currentItemIndex += 1
                playerVc?.refresh()
            }
        }
    }
}
