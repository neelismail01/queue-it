//
//  MySongsResponse.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-22.
//

import Foundation
import MusicKit

struct MySongsResponse: Decodable {
    let data: [Song]
}
