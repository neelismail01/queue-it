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
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject var viewModel: ViewModel
    @State var query = ""
    
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
                    Task {
                        await viewModel.addSongToFirebaseQueue(songId: song.id.rawValue)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
}

