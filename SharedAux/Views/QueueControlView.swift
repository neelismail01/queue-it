//
//  QueueControlView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-03.
//

import SwiftUI

struct QueueControlView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var showDialog = false
    
    var topRow: some View {
        let topButtonText = viewModel.applicationState == .queueOwner ? "End Queue" : "Leave Queue"
        let dialogText = viewModel.applicationState == .queueOwner ? "End this queue" : "Leave this queue"
        
        return HStack {
            Button {
                showDialog = true
            } label: {
                Text(topButtonText)
                    .frame(width: 100, height: 50)
                    .background(.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .confirmationDialog(dialogText, isPresented: $showDialog) {
                        Button(topButtonText) {
                            // viewModel.
                        }
                    }
            }
            Spacer()
            NavigationLink(destination: SearchView()) {
                Text("Add a song")
                    .frame(width: 100, height: 50)
                    .background(.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    var queue: some View {
        let songAdditions = viewModel.activeQueue?.songAdditions ?? []
        return List(songAdditions) { song in
            HStack {
                AsyncImage(url: URL(string: song.songArtworkUrl))
                    .frame(width: 50, height: 50, alignment: .center)
                VStack(alignment: .leading) {
                    Text(song.songName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(song.songArtist)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "play.circle")
            }
        }
    }
    
    var body: some View {
        VStack {
            topRow
            queue
        }
        .frame(alignment: .top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.fetchFirebaseQueue()
        }
    }
}
