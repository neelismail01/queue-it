//
//  ContentView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-12.
//

import SwiftUI
import MediaPlayer

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    @State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    var body: some View {
        NavigationView {
            if viewModel.musicAuthorizationStatus == .authorized {
                WelcomeView()
            } else {
                CreateQueueView(musicPlayer: self.$musicPlayer)
            }
        }
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
