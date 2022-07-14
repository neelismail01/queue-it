//
//  AlbumView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-12.
//

import SwiftUI
import MusicKit

struct AlbumView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State var detailedAlbumInfo: Album?
    @State var state: ViewState = .loading
    let album: Album
    
    var body: some View {
        VStack {
            if state == .loading {
                Text("Loading...")
            } else {
                ScrollView {
                    AsyncImage(url: detailedAlbumInfo!.artwork?.url(width: 200, height: 200))
                    Text(detailedAlbumInfo!.title)
                        .fontWeight(.bold)
                    Text(detailedAlbumInfo!.artistName)
                    ForEach(detailedAlbumInfo!.tracks ?? []) { track in
                        AsyncImage(url: track.artwork?.url(width: 50, height: 50))
                            .frame(width: 50, height: 50, alignment: .center)
                            .cornerRadius(5)
                        VStack(alignment: .leading) {
                            Text(track.title)
                                .font(.system(size: 16, weight: .semibold))
                                .lineLimit(1)
                            Text(track.artistName)
                                .font(.system(size: 14, weight: .light))
                                .lineLimit(1)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
