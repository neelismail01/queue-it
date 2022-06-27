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
    
    var body: some View {
            NavigationView {
                if viewModel.musicAuthorizationStatus == .authorized {
                    WelcomeView()
                } else {
                    ZStack {
                        CreateQueueView()
                        PlaybackBarView()
                    }
                }
            }
            .zIndex(1)
            .sheet(isPresented: $viewModel.isPlayerViewPresented, content: {
                PlaybackFullScreenView()
                    .environmentObject(viewModel)
                    .zIndex(2)
            })
            .environmentObject(viewModel)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
