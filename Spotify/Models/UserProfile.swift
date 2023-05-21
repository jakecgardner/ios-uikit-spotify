//
//  UserProfile.swift
//  Spotify
//
//  Created by jake on 2/26/23.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let displayName: String
    let email: String
//    let followers: [String: String]
    let id: String
    let product: String
    let images: [APIImage]
}
