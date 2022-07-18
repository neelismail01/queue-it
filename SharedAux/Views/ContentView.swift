//
//  ContentView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-12.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.applicationState == .loadingApplication {
                LoadingApplicationView()
            } else if viewModel.applicationState == .unauthorized {
                WelcomeView()
            } else if viewModel.applicationState == .readyForQueue {
                HomeView()
            } else {
                QueueControlView()
            }
        }
        .onAppear {
            Task {
                await viewModel.requestAppleMusicAuthorization()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
