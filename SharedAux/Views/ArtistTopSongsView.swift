//
//  ArtistTopSongsView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-14.
//

import SwiftUI
import MusicKit

struct ArtistTopSongsView: View {
    
    let topSongs: [Song]
    
    var body: some View {
        VStack {
            ForEach(topSongs, id: \.id) { song in
                MusicItemRow(id: song.id.rawValue,
                             title: song.title,
                             artistName: song.artistName,
                             artworkUrlSmall: song.artwork?.url(width: 100, height: 100),
                             artworkUrlLarge: song.artwork?.url(width: 500, height: 500),
                             isExplicit: song.contentRating == .explicit)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .navigationTitle("Top Songs")
    }
}
