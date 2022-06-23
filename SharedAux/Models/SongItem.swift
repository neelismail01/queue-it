//
//  SongItem.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-23.
//

import Foundation

struct SongItem: Identifiable, Hashable, Decoder {
    var id = UUID()
    let title: String
    let artistName: String
    let imageUrl: URL?
}
