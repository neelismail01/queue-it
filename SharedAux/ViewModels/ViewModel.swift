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
    @Published var songSearchResults: MusicItemCollection<Song>?
    
    func loginWithAppleMusic(_ status: MusicAuthorization.Status) {
        musicAuthorizationStatus = status
    }
    
    func searchAppleMusicCatalog(for query: String) async {
        do {
            let searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
            let response = try await searchRequest.response()
            await MainActor.run {
                self.songSearchResults = response.songs
            }
        } catch {
            print("Music Catalog Search error: \(error)")
        }
    }
}
