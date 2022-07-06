//
//  Queue.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-05.
//

import Foundation
import FirebaseFirestoreSwift

struct Queue: Codable {
    @DocumentID var id: String?
    var name: String
    var joinCode: String
    var songs: [String]
    var active: Bool
}
