//
//  AlbumView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-12.
//

import SwiftUI
import MusicKit
import SDWebImageSwiftUI

struct AlbumView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State var detailedAlbumInfo: Album?
    @State var state: ViewState = .loading
    let album: Album
    
    var body: some View {
        let albums = detailedAlbumInfo?.tracks ?? []
        let albumsWithIndex = albums.enumerated().map({ $0 })
        
        VStack {
            if state == .loading {
                Text("Loading...")
            } else {
                ScrollView {
                    WebImage(url: detailedAlbumInfo!.artwork?.url(width: 500, height: 500))
                        .placeholder(
                            Image(systemName: "music.note")
                        )
                        .resizable()
                        .frame(width: 250, height: 250)
                        .cornerRadius(5)
                    Text(detailedAlbumInfo!.title)
                        .font(.system(size: 22).bold())
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding([.top, .leading, .trailing])

                    Text(detailedAlbumInfo!.artistName)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding([.leading, .trailing])

                    ForEach(albumsWithIndex, id: \.element.id) { index, track in
                        HStack {
                            HStack {
                                Text(String(index + 1))
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                Text(track.title)
                                    .font(.system(size: 16, weight: .medium))
                                    .lineLimit(1)
                                if track.contentRating == .explicit {
                                    Text("E")
                                        .frame(width: 15, height: 15)
                                        .font(.system(size: 8))
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .background(Color(UIColor.systemGray))
                                        .cornerRadius(2.5)
                                }
                            }
                            Spacer()
                            if let queue = viewModel.activeQueue, queue.songAdditions.map({ songAddition in
                                songAddition.songId
                            }).filter({ songId in
                                songId == track.id.rawValue
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
                                                                         songId: track.id.rawValue,
                                                                         songName: track.title,
                                                                        songArtist: track.artistName,
                                                                        songArtworkUrl: track.artwork?.url(width: 100, height: 100)?.absoluteString ?? "", isExplicit: track.contentRating == .explicit)
                                        
                                        await viewModel.addSongToFirebaseQueue(songAddition)
                                        performSuccessHaptic()
                                    }
                                } label: {
                                    Image(systemName: "plus.circle")

                                }
                            }
                        }
                        .frame(height: 50)
                        .padding([.leading, .trailing])
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .navigationBarTitle(album.title)
        .onAppear {
            Task {
                do {
                    self.detailedAlbumInfo = try await viewModel.getAlbumInformation(album)
                    self.state = .ready
                } catch {
                    self.state = .error
                }
            }
        }
    }
    
    func performSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
