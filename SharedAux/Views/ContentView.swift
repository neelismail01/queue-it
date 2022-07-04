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
                if viewModel.musicAuthorizationStatus == .authorized {
                    WelcomeView()
                } else {
                    ZStack {
                        HomeView()
                        // PlaybackBarView()
                    }
                }
            }
            .zIndex(1)
            .sheet(isPresented: $viewModel.isPlayerViewPresented, content: {
                PlaybackFullScreenView()
                    .zIndex(2)
            })

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
