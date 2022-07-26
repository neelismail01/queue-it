//
//  ArtistView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-12.
//

import SwiftUI
import MusicKit
import SDWebImageSwiftUI

struct ArtistView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State var detailedArtistInfo: Artist?
    @State var state: ScreenState = .loading
    
    let artist: Artist
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var loading: some View {
        Text("Loading...")
    }
    
    var topSongsSection: some View {
        let topSongs = detailedArtistInfo?.topSongs ?? []
        return VStack {
            HStack {
                Text("Top Songs")
                    .font(.system(size: 22).bold())
                Spacer()
                NavigationLink {
                    ArtistTopSongsView(topSongs: Array(detailedArtistInfo!.topSongs ?? []))
                } label: {
                    Text("View All")
                        .font(.system(size: 16))
                }
                
            }
            
            ForEach(topSongs.count > 4 ? Array(topSongs[...4]) : Array(topSongs), id: \.id) { song in
                MusicItemRow(id: song.id.rawValue,
                             title: song.title,
                             artistName: song.artistName,
                             artworkUrlSmall: song.artwork?.url(width: 100, height: 100),
                             artworkUrlLarge: song.artwork?.url(width: 500, height: 500),
                             isExplicit: song.contentRating == .explicit)
            }
        }
        .padding(.bottom, 15)
    }
    
    var albumsSection: some View {
        let albums = detailedArtistInfo?.albums ?? []

        return VStack {
            HStack {
                Text("Albums")
                    .font(.system(size: 22).bold())
                Spacer()
            }

            LazyVGrid(columns: columns) {
                ForEach(albums) { album in
                    NavigationLink {
                        AlbumView(album: album)
                    } label: {
                        AlbumInformation(album: album)
                    }
                }
            }
        }
    }
    
    var artistInformation: some View {
        ScrollView {
            topSongsSection
                .padding()
            albumsSection
                .padding()
        }
    }
    
    var body: some View {
        VStack {
            if state == .loading {
                loading
            } else {
                artistInformation
            }
        }
        .onAppear {
            Task {
                do {
                    self.detailedArtistInfo = try await viewModel.getArtistInformation(artist)
                    self.state = .ready
                } catch {
                    self.state = .error
                }
            }
        }
        .navigationBarTitle(artist.name)
    }
}

struct AlbumInformation: View {
    let album: Album
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        return VStack(alignment: .leading) {
            AlbumImage(frameWidth: 150,
                       frameHeight: 150,
                       url: album.artwork?.url(width: 300, height: 300))
            HStack() {
                Text(album.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                    .lineLimit(1)
                if album.contentRating == .explicit {
                    Text("E")
                        .frame(width: 15, height: 15)
                        .font(.system(size: 8))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .background(Color(UIColor.systemGray))
                        .cornerRadius(2.5)
                }
                Spacer()
            }
            if let releaseDate = album.releaseDate {
                Text(dateFormatter.string(from: releaseDate))
                    .font(.system(size: 14))
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
    }
}
