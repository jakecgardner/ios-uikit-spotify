//
//  Track.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import Foundation

struct Track: Codable {
    var album: Album?
    let artists: [Artist]
    let availableMarkets: [String]
    let discNumber: Int
    let durationMs: Int
    let explicit: Bool
    let externalUrls: [String: String]
    let id: String
    let name: String
    let trackNumber: Int
    let previewUrl: String?
}
