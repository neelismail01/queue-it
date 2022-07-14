//
//  SearchView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-19.
//

import SwiftUI
import MusicKit
import MediaPlayer

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
            searchResults
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
        
        return List {
            ForEach(songResults, id: \.id) { song in
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
                .onTapGesture {
                    Task {
                        await viewModel.addSongToFirebaseQueue(song)
                    }
                }
            }
            
            ForEach(artistResults, id: \.id) { artist in
                NavigationLink {
                    ArtistView(artist: artist)
                } label: {
                    VStack(alignment: .leading) {
                        Text(artist.name)
                            .font(.system(size: 16, weight: .semibold))
                            .lineLimit(1)
                        Text("Artist")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.gray)
                    }
                }

            }
            
            ForEach(albumResults, id: \.id) { album in
                NavigationLink {
                    AlbumView(album: album)
                } label: {
                    VStack(alignment: .leading) {
                        Text(album.title)
                            .font(.system(size: 16, weight: .semibold))
                            .lineLimit(1)
                        Text("Album - \(album.artistName)")
                            .font(.system(size: 14, weight: .light))
                            .lineLimit(1)
                            .foregroundColor(.gray)
                    }
                }
            }
                               
                               
        }
        .listStyle(PlainListStyle())
    }
    
}

