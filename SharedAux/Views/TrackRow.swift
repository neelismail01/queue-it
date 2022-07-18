//
//  TrackRow.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-16.
//

import SwiftUI
import MusicKit
import SDWebImageSwiftUI

struct TrackRow: View {
    
    @EnvironmentObject var viewModel: ViewModel
    let song: Song
    
    var body: some View {
        HStack {
            WebImage(url: song.artwork?.url(width: 100, height: 100))
                .placeholder(
                    Image(systemName: "music.note")
                )
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Text(song.title)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    if  song.contentRating == .explicit {
                        Text("E")
                            .frame(width: 15, height: 15)
                            .font(.system(size: 8))
                            .foregroundColor(Color(UIColor.systemBackground))
                            .background(Color(UIColor.systemGray))
                            .cornerRadius(2.5)
                    }
                }
                Spacer()
                Text(song.artistName)
                    .font(.system(size: 14, weight: .light))
                    .lineLimit(1)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
            if let queue = viewModel.activeQueue, queue.songAdditions.map({ songAddition in
                songAddition.songId
            }).filter({ songId in
                songId == song.id.rawValue
            }).count > 0 {
                Text("Added")
                    .font(.system(size: 10))
                    .padding(10)
                    .foregroundColor(Color(UIColor.systemGray))
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(.infinity)
            } else {
                Button {
                    Task {
                        let songAddition = SongAddition(addedBy: "Neel Ismail",
                                                         songId: song.id.rawValue,
                                                         songName: song.title,
                                                         songArtist: song.artistName,
                                                        songArtworkUrl: song.artwork?.url(width: 100, height: 100)?.absoluteString ?? "", isExplicit: song.contentRating == .explicit)
                        
                        await viewModel.addSongToFirebaseQueue(songAddition)
                        performSuccessHaptic()
                    }
                } label: {
                    Image(systemName: "plus.circle")

                }
            }
        }
    }
    
    func performSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
