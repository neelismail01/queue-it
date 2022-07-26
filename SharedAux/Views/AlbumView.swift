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
    @State var state: ScreenState = .loading
    
    let album: Album
    
    var albumInformation: some View {
        VStack {
            AlbumImage(frameWidth: 250,
                       frameHeight: 250,
                       url: detailedAlbumInfo!.artwork?.url(width: 500, height: 500))
            
            Text(detailedAlbumInfo!.title)
                .font(.system(size: 22).bold())
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding([.top, .leading, .trailing])
            
            Text(detailedAlbumInfo!.artistName)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding([.leading, .trailing])
        }
    }
    
    var albumTrackList: some View {
        let albums = detailedAlbumInfo?.tracks ?? []
        let albumsWithIndex = albums.enumerated().map({ $0 })
        
        return ForEach(albumsWithIndex, id: \.element.id) { index, track in
            AlbumTrackRow(track: track, index: index)
        }
        .frame(height: 40)
        .padding([.leading, .trailing])
    }
    
    var body: some View {
        VStack {
            if state == .ready {
                ScrollView {
                    albumInformation
                    albumTrackList
                }
            } else {
                Text("Loading...")
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
}

struct AlbumTrackRow: View {
    
    let track: Track
    let index: Int
    
    var body: some View {
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
            
            Spacer()
            
            AddSongButton(songId: track.id.rawValue,
                          songName: track.title,
                          songArtist: track.artistName,
                          songArtworkUrlSmall: track.artwork?.url(width: 100,
                                                                  height: 100)?.absoluteString ?? "",
                          songArtworkUrlLarge: track.artwork?.url(width: 500,
                                                                  height: 500)?.absoluteString ?? "",
                          isExplicit: track.contentRating == .explicit)
        }
    }
}
