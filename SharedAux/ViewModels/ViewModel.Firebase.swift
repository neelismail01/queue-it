//
//  ViewModel.Firebase.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import MusicKit

/*
    This extension handles interactions with Firebase
*/
extension ViewModel {
    
    private func createJoinCode() -> String {
        let randomString = UUID().uuidString
        let lowerBound = randomString.index(randomString.startIndex, offsetBy: 0)
        let upperBound = randomString.index(randomString.startIndex, offsetBy: 6)
        return randomString[lowerBound..<upperBound].uppercased()
    }
    
    func createFirebaseQueue(queueName: String) async {
        do {
            let docRef = db.collection("Queues").document()
            let joinCode = createJoinCode()
            
            let data = Queue(name: queueName,
                             joinCode: joinCode,
                             songAdditions: [],
                             currentSongIndex: nil,
                             isActive: true)
            
            try docRef.setData(from: data)
            firebaseDocId = docRef.documentID
            applicationState = .queueOwner
        } catch {
            print("An error occurred while creating a firebase queue: \(error)")
        }
    }
    
    func joinFirebaseQueue(joinCode: String) async {
        do {
            let query = db.collection("Queues")
                .whereField("joinCode", isEqualTo: joinCode)
                .whereField("isActive", isEqualTo: true)
            
            let snapshot = try await query.getDocuments()
            
            if snapshot.count > 0 {
                await MainActor.run {
                    firebaseDocId = snapshot.documents[0].documentID
                    applicationState = .queueContributor
                }
            }
        } catch {
            print("An error occurred while joining a firebase queue: \(error)")
        }
    }
    
    func fetchFirebaseQueue() {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        db.collection("Queues").document(firebaseDocId).addSnapshotListener { [weak self] snapshot, error in
            if error != nil {
                print("An error occurred fetching this queue from firebase: \(error.debugDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                return
            }
            
            do {
                self?.activeQueue = try snapshot.data(as: Queue.self)
                if let activeQueue = self?.activeQueue {
                    if !activeQueue.isActive {
                        self?.applicationState = .readyForQueue
                    }
                }
            } catch {
                print("An error occurred while reading the firebase snapshot: \(error)")
            }
        }
    }
    
    func addSongToFirebaseQueue(songId: String,
                                songName: String,
                                songArtist: String,
                                songArtworkUrlSmall: String,
                                songArtworkUrlLarge: String,
                                isExplicit: Bool) async {
        
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        do {
            let songAddition = SongAddition(songId: songId,
                                            songName: songName,
                                            songArtist: songArtist,
                                            songArtworkUrlSmall: songArtworkUrlSmall,
                                            songArtworkUrlLarge: songArtworkUrlLarge,
                                            isExplicit: isExplicit)
            
            let encodedSongAddition = try Firestore.Encoder().encode(songAddition)
            
            try await db.collection("Queues").document(firebaseDocId).updateData(
                ["songAdditions": FieldValue.arrayUnion([encodedSongAddition])])
        } catch {
            print("An error occurred while adding a song to your firebase queue: \(error)")
        }
    }
    
    func updateCurrentSongIndex() async {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
                
        do {
            try await db.collection("Queues").document(firebaseDocId).updateData(
                ["currentSongIndex": musicPlayer.indexOfNowPlayingItem])
        } catch {
            print("An error occurred while updating the current song index: \(error)")
        }
    }
    
    func leaveQueue() async {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        if applicationState == .queueOwner {
            do {
                musicPlayer.pause()
                try await db.collection("Queues").document(firebaseDocId).updateData(
                    ["isActive": false])
            } catch {
                print("An error occurred while changing the state of this queue: \(error)")
            }
        }
        
        await MainActor.run {
            self.firebaseDocId = nil
            activeQueue = nil
            searchResults = nil
            isSongPlaying = false
            isPlayerViewPresented = false
            queueBeingManaged = false
            applicationState = .readyForQueue
        }
    }
}
