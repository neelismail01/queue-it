//
//  ViewModel.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-16.
//

import Foundation
import MusicKit
import MediaPlayer
import Firebase
import FirebaseFirestoreSwift

enum ApplicationState {
    case unauthorized
    case readForQueue
    case queueOwner
    case queueContributor
}

class ViewModel: ObservableObject {
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    @Published var applicationState: ApplicationState = .unauthorized
    @Published var musicAuthorizationStatus: MusicAuthorization.Status = .notDetermined
    @Published var songSearchResults: [Song] = []
    
    @Published var isPlayerViewPresented = false
    
    func loginWithAppleMusic(_ status: MusicAuthorization.Status) {
        musicAuthorizationStatus = status
        if status == .authorized {
            applicationState = .readForQueue
        }
    }
    
    
    private var db = Firestore.firestore()
    var firebaseDocId: String?
    var activeQueue: Queue?
    
    var currentSongQueueIndex: Int = -1
    
    @Published var currentlyPlayingItem: MPMediaItem?
    @Published var isSongPlaying = false
    
    func createFirebaseQueue(nameOfQueue: String) async {
        do {
            let docRef = db.collection("Queues").document()
            
            let randomString = UUID().uuidString
            let lowerBound = randomString.index(randomString.startIndex, offsetBy: 0)
            let upperBound = randomString.index(randomString.startIndex, offsetBy: 6)
            let joinCode = randomString[lowerBound..<upperBound].uppercased()
            let data = Queue(name: nameOfQueue, joinCode: joinCode, songs: [], active: true)
            
            try docRef.setData(from: data)
            self.firebaseDocId = docRef.documentID
            self.applicationState = .queueOwner
        } catch {
            print("An error occurred while creating a firebase queue: \(error)")
        }
    }
    
    func joinFirebaseQueue(joinCode: String) async {
        do {
            let query = db.collection("Queues").whereField("joinCode", isEqualTo: joinCode)
            let snapshot = try await query.getDocuments()
            if snapshot.count == 0 {
                print("no queue with this code exists")
                return
            }
            
            self.firebaseDocId = snapshot.documents[0].documentID
            self.applicationState = .queueContributor
        } catch {
            print("An error occurred while joining a firebase queue: \(error)")
        }
    }
    
    func fetchFirebaseQueue() {
        guard let docId = firebaseDocId else {
            print("firebaseDocId is undefined")
            return
        }
        
        db.collection("Queues").document(docId).addSnapshotListener { snapshot, error in
            self.activeQueue = try? snapshot?.data(as: Queue.self)
        }
    }
    
    func addSongToFirebaseQueue(songId: String) async {
        guard let docId = firebaseDocId else {
            print("firebaseDocId is undefined")
            return
        }
        
        do {
            try await db.collection("Queues").document(docId).updateData(
                ["songs": FieldValue.arrayUnion([songId])])
            
            if applicationState == .queueOwner && musicPlayer.nowPlayingItem == nil {
                await playNextSong()
            }
        } catch {
            print("An error occurred while adding a song to your firebase queue: \(error)")
        }
    }
    
    @MainActor func checkCurrentlyPlayingSong() {
        guard let currentSong = musicPlayer.nowPlayingItem else {
            return
        }
        
        if currentSong.playbackDuration - musicPlayer.currentPlaybackTime < 1 {
            playNextSong()
        }
    }
    
    @MainActor func playNextSong() {
        guard let songQueue = activeQueue?.songs else {
            return
        }
        
        if songQueue.count > 0 {
            if currentSongQueueIndex < songQueue.count - 1 {
                currentSongQueueIndex += 1
            } else {
                currentSongQueueIndex = 0
            }
            musicPlayer.setQueue(with: [songQueue[currentSongQueueIndex]])
            musicPlayer.play()
            currentlyPlayingItem = musicPlayer.nowPlayingItem
            isSongPlaying = true
        }
    }
    
    func searchAppleMusicCatalog(for query: String) async {
        do {
            if !query.isEmpty {
                let searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
                let response = try await searchRequest.response()
                print(response.songs)
                await MainActor.run {
                    self.songSearchResults = response.songs.compactMap { $0 }
                }
            } else {
                songSearchResults = []
            }
        } catch {
            print("Music Catalog Search error: \(error)")
        }
    }
}
