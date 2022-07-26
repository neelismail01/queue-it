//
//  SongAddition.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-23.
//

import Foundation

struct SongAddition: Identifiable, Codable {
    var id: String = UUID().uuidString
    var songId: String
    var songName: String
    var songArtist: String
    var songArtworkUrlSmall: String
    var songArtworkUrlLarge: String
    var isExplicit: Bool
}
