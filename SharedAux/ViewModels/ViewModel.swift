//
//  ViewModel.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-16.
//

import Foundation
import MusicKit
import Firebase
import MediaPlayer

class ViewModel: ObservableObject {
    var db = Firestore.firestore()
    var firebaseDocId: String?
    var musicPlayer = MPMusicPlayerController.applicationQueuePlayer
    var checkSongTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var queueBeingManaged = false
    
    // Application and authorization state
    @Published var applicationState: ApplicationState = .loadingApplication
    
    // Search results
    @Published var searchResults: SearchResults?
    
    // Queue information
    @Published var activeQueue: Queue?
    
    // Music playback
    @Published var isSongPlaying = false
    @Published var isPlayerViewPresented = false
}
