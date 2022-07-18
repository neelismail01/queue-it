//
//  SearchView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-19.
//

import SwiftUI
import MusicKit
import MediaPlayer
import SDWebImageSwiftUI

enum SearchDestination {
    case artist
    case album
}

struct SearchView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject var viewModel: ViewModel
    @State var query = ""
    @State var destination: SearchDestination? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            if !query.isEmpty {
                searchResults
            } else {
                
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
                        TrackRow(song: song)
                    }
                } header: {
                    Text("Songs")
                }
                
                Section {
                    ForEach(artistResults, id: \.id) { artist in
                        NavigationLink {
                            ArtistView(artist: artist)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "music.mic")
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(5)
                                        .background(Color(UIColor.systemGray6))
                                    Text(artist.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .lineLimit(1)
                                }
                            }
                            .frame(height: 50)
                        }
                        
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
                                WebImage(url: album.artwork?.url(width: 100, height: 100))
                                    .placeholder(
                                        Image(systemName: "music.note")
                                    )
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(album.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .lineLimit(1)
                                        if album.contentRating == .explicit {
                                            Text("E")
                                                .frame(width: 15, height: 15)
                                                .font(.system(size: 8))
                                                .foregroundColor(Color(UIColor.systemBackground))
                                                .background(Color(UIColor.systemGray))
                                                .cornerRadius(2.5)
                                        }
                                    }
                                    Text(album.artistName)
                                        .font(.system(size: 14, weight: .light))
                                        .lineLimit(1)
                                        .foregroundColor(.gray)
                                }
                                .frame(height: 50)
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
    
}

