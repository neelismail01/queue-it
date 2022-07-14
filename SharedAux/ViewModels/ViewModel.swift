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
    case readyForQueue
    case queueOwner
    case queueContributor
}

enum UpdateCurrentSongIndexDirection {
    case forward
    case backward
}

class ViewModel: ObservableObject {
    private var db = Firestore.firestore()
    private var firebaseDocId: String?
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    // Application and authorization state
    @Published var applicationState: ApplicationState = .unauthorized
    @Published var musicAuthorizationStatus: MusicAuthorization.Status = .notDetermined
    
    // Search results
    @Published var searchResults: SearchResults?
    
    // Queue information
    @Published var activeQueue: Queue?
    
    // Music playback
    @Published var isSongPlaying = false
    @Published var isPlayerViewPresented = false
    
    func createFirebaseQueue(nameOfQueue: String) async {
        do {
            let docRef = db.collection("Queues").document()
            
            let randomString = UUID().uuidString
            let lowerBound = randomString.index(randomString.startIndex, offsetBy: 0)
            let upperBound = randomString.index(randomString.startIndex, offsetBy: 6)
            let joinCode = randomString[lowerBound..<upperBound].uppercased()
            let data = Queue(name: nameOfQueue,
                             joinCode: joinCode,
                             songAdditions: [],
                             currentSongIndex: 0,
                             active: true)
            
            try docRef.setData(from: data)
            self.firebaseDocId = docRef.documentID
            self.applicationState = .queueOwner
        } catch {
            print("An error occurred while creating a firebase queue: \(error)")
        }
    }
    
    func joinFirebaseQueue(joinCode: String) async {
        do {
            let query = db.collection("Queues")
                .whereField("joinCode", isEqualTo: joinCode)
                .whereField("active", isEqualTo: true)
            let snapshot = try await query.getDocuments()
            if snapshot.count == 0 {
                print("no queue with this code exists")
                return
            }
            
            await MainActor.run {
                self.firebaseDocId = snapshot.documents[0].documentID
                self.applicationState = .queueContributor
            }
        } catch {
            print("An error occurred while joining a firebase queue: \(error)")
        }
    }
    
    func leaveQueue() async {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        if applicationState == .queueOwner {
            do {
                musicPlayer.pause()
                isSongPlaying = false
                try await db.collection("Queues").document(firebaseDocId).updateData(
                    ["active": false])
            } catch {
                print("An error occurred while changing the state of this queue: \(error)")
            }
        }
        
        await MainActor.run {
            applicationState = .readyForQueue
        }
    }
    
    func fetchFirebaseQueue() {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        db.collection("Queues").document(firebaseDocId).addSnapshotListener { snapshot, error in
            if error != nil {
                print("An error occurred fetching this queue from firebase: \(error.debugDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                return
            }
            
            do {
                self.activeQueue = try snapshot.data(as: Queue.self)
                if let activeQueue = self.activeQueue {
                    if activeQueue.active == false {
                        self.applicationState = .readyForQueue
                    }
                }
            } catch {
                print("An error occurred while reading the firebase snapshot: \(error)")
            }
        }
    }
    
    func addSongToFirebaseQueue(_ song: Song) async {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        do {
            let songAddition = SongAddition(addedBy: "Neel Ismail",
                                             songId: song.id.rawValue,
                                             songName: song.title,
                                             songArtist: song.artistName,
                                             songArtworkUrl: song.artwork?.url(width: 50, height: 50)?.absoluteString ?? "")
            
            let encodedSongAddition = try Firestore.Encoder().encode(songAddition)
            
            try await db.collection("Queues").document(firebaseDocId).updateData(
                ["songAdditions": FieldValue.arrayUnion([encodedSongAddition])])
            
        } catch {
            print("An error occurred while adding a song to your firebase queue: \(error)")
        }
    }
    
    @MainActor func checkCurrentlyPlayingSong() async {
        guard let songAdditions = activeQueue?.songAdditions else {
            return
        }
        
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            if nowPlayingItem.playbackDuration - musicPlayer.currentPlaybackTime < 1 {
                await goToNextSong()
            }
        } else if songAdditions.count > 0 {
            await playSong()
        }
    }
    
    func goToNextSong() async {
        guard let songAdditions = activeQueue?.songAdditions,
              let currentSongIndex = activeQueue?.currentSongIndex else {
            return
        }
        
        if currentSongIndex < songAdditions.count - 1 {
            await updateCurrentSongIndex(currentSongIndex, songAdditions, .forward)
            await playSong()
        }
    }
    
    func goToPreviousSong() async {
        guard let songAdditions = activeQueue?.songAdditions,
              let currentSongIndex = activeQueue?.currentSongIndex else {
            return
        }
        
        if currentSongIndex > 0 {
            await updateCurrentSongIndex(currentSongIndex, songAdditions, .backward)
            await playSong()
        }
    }
    
    func updateCurrentSongIndex(_ currentSongIndex: Int, _ songAdditions: [SongAddition], _ direction: UpdateCurrentSongIndexDirection) async {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        let updatedSongIndex = direction == .forward ? currentSongIndex + 1 : currentSongIndex - 1

        do {
            try await db.collection("Queues").document(firebaseDocId).updateData(
                ["currentSongIndex": updatedSongIndex])
        } catch {
            print("An error occurred while updating the current song index: \(error)")
        }
    }
    
    @MainActor func playSong() async {
        guard let songAdditions = activeQueue?.songAdditions,
              let currentSongIndex = activeQueue?.currentSongIndex else {
            return
        }
        
        musicPlayer.setQueue(with: [songAdditions[currentSongIndex].songId])
        musicPlayer.play()
        isSongPlaying = true
    }
    
    func loginWithAppleMusic(_ status: MusicAuthorization.Status) {
        musicAuthorizationStatus = status
        if status == .authorized {
            applicationState = .readyForQueue
        }
    }
    
    func searchAppleMusicCatalog(for query: String) async {
        do {
            if !query.isEmpty {
                var searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self, Album.self, Artist.self])
                
                searchRequest.limit = 3
                
                let response = try await searchRequest.response()
                
                let songResults = response.songs.compactMap { $0 }
                let albumResults = response.albums.compactMap { $0 }
                let artistResults = response.artists.compactMap { $0 }
                
                await MainActor.run {
                    self.searchResults = SearchResults(songs: songResults,
                                                       albums: albumResults,
                                                       artists: artistResults)
                }
            }
        } catch {
            print("Music Catalog Search error: \(error)")
        }
    }
    
    func getArtistInformation(_ artist: Artist) async throws -> Artist {
        do {
            let detailedArtist = try await artist.with([.topSongs, .albums])
            return detailedArtist
        } catch {
            print("An error occurred while retrieving the artist's information: \(error)")
            throw error
        }
    }
    
    func getAlbumInformation(_ album: Album) async throws -> Album {
        do {
            let detailedAlbum = try await album.with([.tracks])
            return detailedAlbum
        } catch {
            print("An error occurred while retrieving the album's information: \(error)")
            throw error
        }
    }
}
