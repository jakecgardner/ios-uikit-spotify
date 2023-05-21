//
//  Album.swift
//  Spotify
//
//  Created by jake on 2/27/23.
//

import Foundation

struct Album: Codable {
    let albumType: String
    let availableMarkets: [String]
    let id: String
    var images: [APIImage]
    let name: String
    let releaseDate: String
    let totalTracks: Int
    let artists: [Artist]
}
