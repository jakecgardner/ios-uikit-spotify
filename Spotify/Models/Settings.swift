//
//  Settings.swift
//  Spotify
//
//  Created by jake on 2/26/23.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
