//
//  SongAddition.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-23.
//

import Foundation

struct SongAddition: Identifiable, Codable {
    var id: String = UUID().uuidString
    var addedBy: String
    var songId: String
    var songName: String
    var songArtist: String
    var songArtworkUrl: String
    var isExplicit: Bool
}
