//
//  SharedViews.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import MusicKit

struct AlbumImage: View {
    let frameWidth: CGFloat
    let frameHeight: CGFloat
    let url: URL?
    
    var body: some View {
        WebImage(url: url)
            .placeholder(
                Image(systemName: "music.note")
            )
            .resizable()
            .frame(width: frameWidth, height: frameHeight)
            .cornerRadius(5)
    }
}

struct MusicItemRow: View {
    let id: String
    let title: String
    let artistName: String
    let artworkUrlSmall: URL?
    let artworkUrlLarge: URL?
    let isExplicit: Bool
    var isCurrentSong = false
    var isAddSongButtonVisible = true
    
    var body: some View {
        HStack {
            AlbumImage(frameWidth: 50,
                       frameHeight: 50,
                       url: artworkUrlSmall)
            MusicItemDetails(mainTitle: title,
                             artistName: artistName,
                             isExplicit: isExplicit,
                             isCurrentSong: isCurrentSong)
            Spacer()
            if isAddSongButtonVisible {
                AddSongButton(songId: id,
                              songName: title,
                              songArtist: artistName,
                              songArtworkUrlSmall: artworkUrlSmall?.absoluteString ?? "",
                              songArtworkUrlLarge: artworkUrlLarge?.absoluteString ?? "",
                              isExplicit: isExplicit)
            }
        }
    }
}

struct AddSongButton: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    let songId: String
    let songName: String
    let songArtist: String
    let songArtworkUrlSmall: String
    let songArtworkUrlLarge: String
    let isExplicit: Bool
    
    func performSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    var body: some View {
        let songIsAdded = viewModel.activeQueue?.songAdditions.filter({ $0.songId == songId
        }).count ?? 0 > 0
        
        Group {
            if songIsAdded {
                Text("Added")
                    .font(.system(size: 10))
                    .padding(10)
                    .foregroundColor(Color(UIColor.systemGray))
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(.infinity)
            } else {
                Button {
                    Task {
                        await viewModel.addSongToFirebaseQueue(songId: songId,
                                                               songName: songName,
                                                               songArtist: songArtist,
                                                               songArtworkUrlSmall: songArtworkUrlSmall,
                                                               songArtworkUrlLarge: songArtworkUrlLarge,
                                                               isExplicit: isExplicit)
                        performSuccessHaptic()
                    }
                } label: {
                    Image(systemName: "plus.circle")
                    
                }
            }
        }
    }
}


struct MusicItemDetails: View {
    let mainTitle: String
    let artistName: String
    let isExplicit: Bool
    var isCurrentSong = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Spacer()
            
            HStack {
                if isCurrentSong {
                    Text(mainTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                } else {
                    Text(mainTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                }
                if isExplicit {
                    Text("E")
                        .frame(width: 15, height: 15)
                        .font(.system(size: 8))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .background(Color(UIColor.systemGray))
                        .cornerRadius(2.5)
                }
            }
            
            Spacer()
            
            Text(artistName)
                .font(.system(size: 14, weight: .light))
                .lineLimit(1)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}
