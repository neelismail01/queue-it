//
//  ContentView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-12.
//

import SwiftUI
import MediaPlayer

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.applicationState == .unauthorized {
                WelcomeView()
            } else if viewModel.applicationState == .readForQueue {
                HomeView()
            } else if viewModel.applicationState == .queueOwner {
                ZStack {
                    QueueControlView()
                    PlaybackBarView()
                }
                .zIndex(1)
                .sheet(isPresented: $viewModel.isPlayerViewPresented) {
                    PlaybackFullScreenView()
                        .zIndex(2)
                }
            } else {
                QueueControlView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
