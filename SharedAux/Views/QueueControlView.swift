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
    
    var leaveQueueButton: some View {
        let dialogText = viewModel.applicationState == .queueOwner ? "End this queue" : "Leave this queue"
        
        return Button {
            showDialog = true
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14))
                .cornerRadius(10)
                .confirmationDialog(dialogText, isPresented: $showDialog) {
                    Button(dialogText, role: .destructive) {
                        Task {
                            await viewModel.leaveQueue()
                        }
                    }
                } message: {
                    Text("Are you sure you would like to \(dialogText.lowercased())?")
                }
        }
    }
    
    var addSongButton: some View {
        NavigationLink(destination: SearchView()) {
            HStack {
                Image(systemName: "plus")
                Text("Add Song")
            }
            .font(.system(size: 12))
            .padding(10)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(.infinity)
        }
    }
    
    var nonEmptyQueue: some View {
        let songAdditions = viewModel.activeQueue?.songAdditions ?? []
        let songAdditionsWithIndex = songAdditions.enumerated().map({ $0 })
        return List {
            Section {
                ForEach(songAdditionsWithIndex, id: \.element.id) { index, song in
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
                    }
                }
            } header: {
                Text("Queue:")
                    .font(.headline)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    var emptyQueue: some View {
        return
        VStack {
            Text("The queue is currently empty.")
                .font(.system(size: 16).bold())
                .padding(2.5)
            addSongButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    var body: some View {
        let queueName = viewModel.activeQueue?.name ?? "Queue"
        let songAdditions = viewModel.activeQueue?.songAdditions ?? []
        HStack {
            if songAdditions.isEmpty {
                emptyQueue
            } else {
                nonEmptyQueue
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .safeAreaInset(edge: .bottom, alignment: .center) {
            PlaybackBarView()
                .zIndex(1)
                .sheet(isPresented: $viewModel.isPlayerViewPresented) {
                    PlaybackFullScreenView()
                        .zIndex(2)
                }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(queueName)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                leaveQueueButton
            }
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                addSongButton
            }
        })
        .onAppear {
            viewModel.fetchFirebaseQueue()
        }
    }
}
