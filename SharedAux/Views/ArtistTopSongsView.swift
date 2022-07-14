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
        ForEach(topSongs) { song in
            HStack {
                AsyncImage(url: song.artwork?.url(width: 50, height: 50))
                    .frame(width: 50, height: 50, alignment: .center)
                    .cornerRadius(5)
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    Text("Song - \(song.artistName)")
                        .font(.system(size: 14, weight: .light))
                        .lineLimit(1)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "plus.circle")
            }
        }
    }
}
