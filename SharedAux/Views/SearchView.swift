//
//  SearchView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-19.
//

import SwiftUI
import MusicKit

struct SearchView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State var query = ""
    
    var searchResults: some View {
        let songResults = viewModel.searchResults?.songs ?? []
        var artistResults = viewModel.searchResults?.artists ?? []
        var albumResults = viewModel.searchResults?.albums ?? []
        
        artistResults = artistResults.count > 2 ? Array(artistResults.prefix(upTo: 2)) : artistResults
        albumResults = albumResults.count > 2 ? Array(albumResults.prefix(upTo: 2)) : albumResults
        
        return VStack {
            List {
                Section {
                    ForEach(songResults, id: \.id) { song in
                        MusicItemRow(id: song.id.rawValue,
                                     title: song.title,
                                     artistName: song.artistName,
                                     artworkUrlSmall: song.artwork?.url(width: 100, height: 100),
                                     artworkUrlLarge: song.artwork?.url(width: 500, height: 500),
                                     isExplicit: song.contentRating == .explicit)
                    }
                } header: {
                    Text("Songs")
                }
                
                Section {
                    ForEach(artistResults, id: \.id) { artist in
                        ArtistResult(artist: artist)
                    }
                } header: {
                    Text("Artists")
                }
                
                Section {
                    ForEach(albumResults, id: \.id) { album in
                        NavigationLink {
                            AlbumView(album: album)
                        } label: {
                            HStack {
                                MusicItemRow(id: album.id.rawValue,
                                             title: album.title,
                                             artistName: album.artistName,
                                             artworkUrlSmall: album.artwork?.url(width: 100, height: 100),
                                             artworkUrlLarge: album.artwork?.url(width: 500, height: 500),
                                             isExplicit: album.contentRating == .explicit,
                                             isCurrentSong: false,
                                             isAddSongButtonVisible: false)
                            }
                        }
                    }
                } header: {
                    Text("Albums")
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !query.isEmpty {
                searchResults
            } else {
                EmptyView()
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: query) { newValue in
            Task {
                await viewModel.searchAppleMusicCatalog(for: newValue)
            }
        }
        .onSubmit {
            Task {
                await viewModel.searchAppleMusicCatalog(for: query)
            }
        }
        .navigationTitle("Search Music")
    }
}

struct ArtistResult: View {
    let artist: Artist
    
    var body: some View {
        NavigationLink {
            ArtistView(artist: artist)
        } label: {
            HStack {
                Image(systemName: "music.mic")
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                    .background(Color(UIColor.systemGray6))
                Text(artist.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
            }
            .frame(height: 50, alignment: .leading)
        }
    }
}
