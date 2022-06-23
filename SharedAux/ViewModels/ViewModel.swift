//
//  ViewModel.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-16.
//

import Foundation
import MusicKit

class ViewModel: ObservableObject {
    @Published var musicAuthorizationStatus: MusicAuthorization.Status = .notDetermined
    @Published var songSearchResults: [SongItem] = []
    
    func loginWithAppleMusic(_ status: MusicAuthorization.Status) {
        musicAuthorizationStatus = status
    }
    
    func searchAppleMusicCatalog(for query: String) async {
        do {
            if !query.isEmpty {
                let searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
                let response = try await searchRequest.response()
                await MainActor.run {
                    self.songSearchResults = response.songs.compactMap({
                        return .init(title: $0.title,
                                     artistName: $0.artistName,
                                     imageUrl: $0.artwork?.url(width: 50, height: 50))
                    })
                    // self.songSearchResults = response.songs
                }
            }
        } catch {
            print("Music Catalog Search error: \(error)")
        }
    }
}
