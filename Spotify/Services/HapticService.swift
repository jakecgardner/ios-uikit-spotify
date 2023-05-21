//
//  HapticService.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import UIKit

final class HapticsService {
    static let shared = HapticsService()
    
    private init() {}
    
    public func vibrateSelect() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
