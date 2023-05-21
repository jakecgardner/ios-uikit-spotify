//
//  Artist.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let externalUrls: [String: String]
}
