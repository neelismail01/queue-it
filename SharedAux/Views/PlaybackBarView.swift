//
//  PlaybackBarView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-24.
//

import SwiftUI

struct PlaybackBarView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State var songTime = 0.0
    
    var songDetails: some View {
        HStack {
            if let activeQueue = viewModel.activeQueue,
               let songIndex = viewModel.activeQueue?.currentSongIndex {
                let currentSong = activeQueue.songAdditions[songIndex]
                
                AlbumImage(frameWidth: 40,
                           frameHeight: 40,
                           url: URL(string: currentSong.songArtworkUrlSmall))
                
                MusicItemDetails(mainTitle: currentSong.songName,
                                 artistName: currentSong.songArtist,
                                 isExplicit: currentSong.isExplicit)
            } else {
                AlbumImage(frameWidth: 40,
                           frameHeight: 40,
                           url: nil)
                Text("Not Playing")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
                    .padding(.trailing)
            }
        }
    }
    
    var playPauseButton: some View {
        Button {
            if viewModel.isSongPlaying {
                viewModel.musicPlayer.pause()
            } else {
                viewModel.musicPlayer.play()
            }
        } label: {
            if viewModel.isSongPlaying {
                Image(systemName: "pause.fill")
                    .font(.system(size: 22))
            } else {
                Image(systemName: "play.fill")
                    .font(.system(size: 22))
            }
        }
        .disabled(viewModel.musicPlayer.nowPlayingItem == nil)
    }
    
    var songTimeline: some View {
        HStack {
            if let nowPlayingItem = viewModel.musicPlayer.nowPlayingItem {
                Rectangle()
                    .fill(.blue)
                    .frame(width: UIScreen.main.bounds.size.width * (songTime / nowPlayingItem.playbackDuration),
                           height: 3)
            }
            Rectangle()
                .fill(Color(UIColor.clear))
                .frame(height: 3)
        }
        .background(Color(UIColor.clear))
    }
    
    var body: some View {
        VStack {
            songTimeline
            Spacer()
            HStack {
                songDetails
                Spacer()
                if viewModel.applicationState == .queueOwner {
                    playPauseButton
                }
            }
            .padding([.leading, .trailing])
        }
        .frame(width: UIScreen.main.bounds.size.width, height: 60)
        .background(Color(UIColor.systemGray6))
        .onTapGesture {
            if viewModel.applicationState == .queueOwner {
                viewModel.isPlayerViewPresented = true
            }
        }
        .onReceive(viewModel.checkSongTimer) { _ in
            Task {
                await MainActor.run {
                    songTime = viewModel.musicPlayer.currentPlaybackTime
                }
            }
        }
    }
}
