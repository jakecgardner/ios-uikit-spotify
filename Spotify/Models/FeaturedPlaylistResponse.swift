//
//  FeaturedPlaylistResponse.swift
//  Spotify
//
//  Created by jake on 2/27/23.
//

import Foundation

struct FeaturedPlaylistResponse: Codable {
    let playlists: PlaylistResponse
}

typealias CategoryPlaylistResponse = FeaturedPlaylistResponse

struct PlaylistResponse: Codable {
    let items: [Playlist]
}

