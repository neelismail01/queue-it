//
//  SearchView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-19.
//

import SwiftUI
import MusicKit

struct SearchView: View {
    @State private var query = ""
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search songs, artists, albums", text: $query)
                    .onSubmit {
                        Task {
                            await viewModel.searchAppleMusicCatalog(for: query)
                        }
                    }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            List {
                ForEach(viewModel.songSearchResults!, id: \.id) { song in
                    SearchResult(song: song)
                }
            }
        }
        .padding()
        .navigationTitle("Search Music")
    }
}

struct SearchResult: View {
    var song: Song
    
    var body: some View {
        HStack {
            Text("Song")
            Text("Artist Name")
        }
    }
}

