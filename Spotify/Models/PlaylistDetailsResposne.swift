//
//  PlaylistDetailsResposne.swift
//  Spotify
//
//  Created by jake on 2/28/23.
//

import Foundation

struct PlaylistDetailsResponse: Codable {
    let description: String
    let externalUrls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlaylistTrackResponse
}

struct PlaylistTrackResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: Track
}
