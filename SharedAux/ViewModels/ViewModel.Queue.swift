//
//  ViewModel.Queue.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-23.
//

import Foundation
import MediaPlayer

/*
    This extension handles interactions with the MediaPlayer queue
*/
extension ViewModel {
    
    func checkSongStatus() async {
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            if nowPlayingItem.playbackDuration - musicPlayer.currentPlaybackTime < 2.5 {
                await manageQueue()
            }
        }
        
        if let songAdditions = activeQueue?.songAdditions {
            if musicPlayer.nowPlayingItem == nil && !songAdditions.isEmpty {
                await manageQueue()
            }
        }
        
        if musicPlayer.nowPlayingItem != nil && musicPlayer.currentPlaybackTime < 1 {
            await updateCurrentSongIndex()
        }
        
        await MainActor.run {
            isSongPlaying = musicPlayer.playbackState == .playing
        }
    }

    func goToNextSong() async {
        guard let songAdditions = activeQueue?.songAdditions else {
            return
        }
        
        if musicPlayer.indexOfNowPlayingItem < songAdditions.count - 1 {
            await addNextSongToQueue()
        }
        
        musicPlayer.skipToNextItem()
    }

    func goToPreviousSong() {
        if musicPlayer.currentPlaybackTime < 5 {
            musicPlayer.skipToPreviousItem()
        } else {
            musicPlayer.skipToBeginning()
        }
    }

    func manageQueue() async {
        guard let songAdditions = activeQueue?.songAdditions else {
            return
        }
        
        if !queueBeingManaged {
            await MainActor.run {
                queueBeingManaged = true
            }
            
            if songAdditions.count > 0 && !musicPlayer.isPreparedToPlay {
                await initializeQueue(with: songAdditions[0].songId)
            } else if musicPlayer.indexOfNowPlayingItem < songAdditions.count - 1 {
                await addNextSongToQueue()
            }
            
            await MainActor.run {
                queueBeingManaged = false
            }
        }
    }

    func initializeQueue(with songId: String) async {
        do {
            musicPlayer.setQueue(with: [songId])
            try await musicPlayer.prepareToPlay()
            musicPlayer.play()
        } catch {
            print("An error occurred while initializing the queue: \(error)")
        }
    }

    func addNextSongToQueue() async {
        guard let songAdditions = activeQueue?.songAdditions else {
            return
        }
        
        do {
            let nextSongIndex = musicPlayer.indexOfNowPlayingItem + 1
            let nextSongId = songAdditions[nextSongIndex].songId
            
            try await musicPlayer.perform { queue in
                if !queue.items.contains(where: { item in item.playbackStoreID == nextSongId }) {
                    let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [nextSongId])
                    queue.insert(descriptor, after: queue.items.last)
                }
            }
        } catch {
            print("An error occurred while adding the next song to the queue: \(error)")
        }
    }
}
