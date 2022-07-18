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
            ForEach(topSongs) { song in
                TrackRow(song: song)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .navigationTitle("Top Songs")
    }
}
