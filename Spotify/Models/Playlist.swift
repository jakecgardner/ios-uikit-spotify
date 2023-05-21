//
//  Playlist.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let externalUrls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
}

