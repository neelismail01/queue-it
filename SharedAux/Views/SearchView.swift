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
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchBar()
            
            List {
                ForEach(viewModel.songSearchResults, id: \.id) { song in
                    SearchResult(song: song)
                }
            }
            .listStyle(PlainListStyle())
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Search Music")
    }
}

struct SearchBar: View {
    @State private var query = ""
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search songs, artists, albums", text: $query)
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
        .padding([.leading, .trailing, .top, .bottom])
    }
}

struct SearchResult: View {
    var song: SongItem
    
    var body: some View {
        HStack {
            AsyncImage(url: song.imageUrl)
                .frame(width: 50, height: 50, alignment: .center)
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(song.artistName)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "play.circle")
        }
    }
}

