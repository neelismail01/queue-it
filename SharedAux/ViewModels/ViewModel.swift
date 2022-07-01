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
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @Published var musicAuthorizationStatus: MusicAuthorization.Status = .notDetermined
    
    @Published var songSearchResults: [Song] = []
    
    var queue: [String] = []
    var currentSongQueueIndex: Int = -1
    
    @Published var currentlyPlayingItem: MPMediaItem?
    @Published var isSongPlaying = false
    
    @Published var isPlayerViewPresented = false
    
    
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
            if currentSong.playbackDuration - musicPlayer.currentPlaybackTime < 1 {
                playNextSong()
            } else {
                currentlyPlayingItem = currentSong
            }
        }
    }
    
    func addSongToQueue(_ songId: String) {
        queue.append(songId)
        if musicPlayer.nowPlayingItem == nil {
            playNextSong()
        }
    }
    
    func playNextSong() {
        if currentSongQueueIndex < queue.count - 1 {
            currentSongQueueIndex += 1
        } else {
            currentSongQueueIndex = 0
        }
        musicPlayer.setQueue(with: [queue[currentSongQueueIndex]])
        musicPlayer.play()
        currentlyPlayingItem = musicPlayer.nowPlayingItem
        isSongPlaying = true
    }
}
