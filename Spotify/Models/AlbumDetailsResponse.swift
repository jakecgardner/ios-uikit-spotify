//
//  AlbumResponse.swift
//  Spotify
//
//  Created by jake on 2/28/23.
//

import Foundation

struct AlbumDetailsResponse: Codable {
    let albumType: String
    let artists: [Artist]
    let availableMarkets: [String]
    let externalUrls: [String: String]
    let id: String
    let images: [APIImage]
    let label: String
    let name: String
    let tracks: TrackResponse
    let totalTracks: Int
}

struct TrackResponse: Codable {
    let items: [Track]
}
