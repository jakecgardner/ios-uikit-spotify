//
//  NewReleasesResponse.swift
//  Spotify
//
//  Created by jake on 2/27/23.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumResponse
}

struct AlbumResponse: Codable {
    let items: [Album]
}
