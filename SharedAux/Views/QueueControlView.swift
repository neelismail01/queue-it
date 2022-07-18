//
//  QueueControlView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-03.
//

import SwiftUI
import SDWebImageSwiftUI

struct QueueControlView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State private var showDialog = false
    @State private var showShareSheet = false
    
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
            .frame(maxWidth: .infinity)
            .font(.system(size: 14).bold())
            .padding(10)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(5)
        }
    }
    
    var inviteButton: some View {
        Button {
            showShareSheet = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Invite")
            }
            .frame(maxWidth: .infinity)
            .font(.system(size: 14).bold())
            .padding(10)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(5)
        }
    }
    
    var nonEmptyQueue: some View {
        let songAdditions = viewModel.activeQueue?.songAdditions ?? []
        let songAdditionsWithIndex = songAdditions.enumerated().map({ $0 })
        let currentSongIndex = viewModel.activeQueue?.currentSongIndex
        return VStack(alignment: .leading) {
            Text("Queue")
                .font(.system(size: 18).bold())
                .padding([.top, .leading])
                .padding(.bottom, 5)
            
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(songAdditionsWithIndex, id: \.element.id) { index, song in
                        QueueItem(song: song, isCurrentSong: index == currentSongIndex)
                            .id(index)
                    }
                }
                .onChange(of: viewModel.activeQueue?.currentSongIndex) { _ in
                    if let scrollIndex = viewModel.activeQueue?.currentSongIndex {
                        withAnimation {
                            proxy.scrollTo(scrollIndex, anchor: .top)
                        }
                    }
                }
            }
        }
        .padding(.bottom)
    }
    
    var emptyQueue: some View {
        return Text("The queue is currently empty.")
            .font(.system(size: 16).bold())
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(2.5)
    }
    
    var body: some View {
        let songAdditions = viewModel.activeQueue?.songAdditions ?? []
        VStack {
            HStack {
                inviteButton
                addSongButton
            }
            .padding()
            
            if songAdditions.isEmpty {
                emptyQueue
            } else {
                nonEmptyQueue
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .navigationTitle(viewModel.activeQueue?.name ?? "")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                leaveQueueButton
            }
        })
        .sheet(isPresented: $showShareSheet, content: {
            ShareSheet(items: ["You are being invited to a queue on Shared Aux! Here is the code to join: \(viewModel.activeQueue?.joinCode ?? "")"])
        })
        .onAppear {
            viewModel.fetchFirebaseQueue()
        }
        .onReceive(viewModel.checkSongTimer) { _ in
            viewModel.insertNextSongIntoApplicationQueue()
        }
    }
}

struct QueueItem: View {
    let song: SongAddition
    let isCurrentSong: Bool
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: song.songArtworkUrl))
                .placeholder(
                    Image(systemName: "music.note")
                )
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    if isCurrentSong {
                        Text(song.songName)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    } else {
                        Text(song.songName)
                            .font(.system(size: 14))
                    }
                    if  song.isExplicit {
                        Text("E")
                            .frame(width: 15, height: 15)
                            .font(.system(size: 8))
                            .foregroundColor(Color(UIColor.systemBackground))
                            .background(Color(UIColor.systemGray))
                            .cornerRadius(2.5)
                    }
                }
                Spacer()
                Text(song.songArtist)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(UIColor.systemGray))
                Spacer()
            }
            Spacer()
        }
        .padding(.leading)
        .padding([.top], 5)
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
}
