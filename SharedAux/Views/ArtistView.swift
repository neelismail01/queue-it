//
//  ArtistView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-12.
//

import SwiftUI
import MusicKit

enum ViewState {
    case loading
    case ready
    case error
}

struct ArtistView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State var detailedArtistInfo: Artist?
    @State var state: ViewState = .loading
    let artist: Artist
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return VStack {
            if state == .loading {
                Text("Loading...")
            } else {
                ScrollView {
                    if let topSongs = detailedArtistInfo?.topSongs {
                        HStack {
                            Text("Top Songs")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            NavigationLink {
                                ArtistTopSongsView(topSongs: Array(detailedArtistInfo!.topSongs ?? []))
                            } label: {
                                Text("View All")
                            }

                        }
                        ForEach(topSongs.count > 5 ? Array(topSongs[...5]) : Array(topSongs)) { song in
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
                        }
                    }
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(artist.albums ?? []) { album in
                                NavigationLink {
                                    AlbumView(album: album)
                                } label: {
                                    VStack {
                                        AsyncImage(url: album.artwork?.url(width: 150, height: 150))
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(10)
                                        Text(album.title)
                                        if let releaseDate = album.releaseDate {
                                            Text(dateFormatter.string(from: releaseDate))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
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
