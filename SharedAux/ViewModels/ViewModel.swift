//
//  ViewModel.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-16.
//

import Foundation
import MusicKit
import MediaPlayer

class ViewModel: ObservableObject {
    @Published var musicAuthorizationStatus: MusicAuthorization.Status = .notDetermined
    
    @Published var songSearchResults: [Song] = []
    
    @Published var currentlyPlayingItem: MPMediaItem?
    @Published var isSongPlaying = false
    
    @Published var isPlayerViewPresented = false
    
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func loginWithAppleMusic(_ status: MusicAuthorization.Status) {
        musicAuthorizationStatus = status
    }
    
    func searchAppleMusicCatalog(for query: String) async {
        do {
            if !query.isEmpty {
                let searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
                let response = try await searchRequest.response()
                await MainActor.run {
                    self.songSearchResults = response.songs.compactMap { $0 }
                }
            }
        } catch {
            print("Music Catalog Search error: \(error)")
        }
    }
    
    func checkCurrentlyPlayingSong() {
        if let currentSong = musicPlayer.nowPlayingItem {
            if currentSong != currentlyPlayingItem {
                currentlyPlayingItem = currentSong
            }
        }
    }
}
