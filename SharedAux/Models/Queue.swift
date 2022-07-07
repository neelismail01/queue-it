//
//  Queue.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-05.
//

import Foundation
import FirebaseFirestoreSwift
import MusicKit

struct Queue: Codable {
    @DocumentID var id: String?
    var name: String
    var joinCode: String
    var songAdditions: [SongAddition]
    var active: Bool
}

struct SongAddition: Identifiable, Codable {
    var id: String = UUID().uuidString
    var addedBy: String
    var songId: String
    var songName: String
    var songArtist: String
    var songArtworkUrl: String
}
