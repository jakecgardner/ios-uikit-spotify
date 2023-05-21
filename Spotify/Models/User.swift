//
//  User.swift
//  Spotify
//
//  Created by jake on 2/27/23.
//

import Foundation

struct User: Codable {
    let displayName: String
    let externalUrls: [String: String]
    let id: String
}
