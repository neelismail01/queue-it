//
//  SearchView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-19.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct SearchView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @FocusState var searchFieldFocused: Bool
    @State var query = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            searchBar
            searchResults
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Search Music")
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search songs, artists, albums", text: $query)
                .focused($searchFieldFocused)
        }
        .padding(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
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
        .padding()
    }
    
    var searchResults: some View {
        List {
            ForEach(viewModel.songSearchResults, id: \.id) { song in
                HStack {
                    AsyncImage(url: song.artwork?.url(width: 50, height: 50))
                        .frame(width: 50, height: 50, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.system(size: 16, weight: .semibold))
                        Text(song.artistName)
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "play.circle")
                }
                .onTapGesture {
                    searchFieldFocused = false
                    viewModel.musicPlayer.setQueue(with: [song.id.rawValue])
                    viewModel.musicPlayer.play()
                    viewModel.isSongPlaying = true
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
}

