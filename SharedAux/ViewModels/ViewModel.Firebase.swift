//
//  ViewModel.Firebase.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

extension ViewModel {
    
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
    
    func addSongToFirebaseQueue(_ songAddition: SongAddition) async {
        guard let firebaseDocId = firebaseDocId else {
            return
        }
        
        do {
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
}
