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
    var currentSongIndex: Int
    var isActive: Bool
}
