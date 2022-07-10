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
    
    var albumImagePlaceholder: some View {
        Image(systemName: "music.note")
            .frame(width: 40, height: 40, alignment: .center)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var songDetails: some View {
        let currentSong = viewModel.musicPlayer.nowPlayingItem
        return HStack {
            if let song = currentSong {
                if let songArtwork = song.artwork?.image(at: CGSize(width: 40, height: 40)) {
                    Image(uiImage: songArtwork)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    albumImagePlaceholder
                }
                VStack(alignment: .leading) {
                    Text(currentSong?.title ?? "Unknown Song")
                        .font(.system(size: 14, weight: .semibold))
                    Text(currentSong?.artist ?? "Unknown Artist")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 5)
                .padding(.trailing)
            } else {
                albumImagePlaceholder
                Text("Not Playing")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
                    .padding(.trailing)
            }
        }
    }
    
    var playPauseButton: some View {
        return HStack {
            if viewModel.musicPlayer.nowPlayingItem == nil {
                Image(systemName: "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            } else if viewModel.isSongPlaying {
                Button {
                    viewModel.musicPlayer.pause()
                    viewModel.isSongPlaying = false
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 22))
                }
            } else {
                Button {
                    viewModel.musicPlayer.play()
                    viewModel.isSongPlaying = true
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 22))
                }
            }
        }
    }
    
    var songTimeline: some View {
        let currentSong = viewModel.musicPlayer.nowPlayingItem
        return HStack {
            if let song = currentSong {
                Rectangle()
                    .fill(.blue)
                    .frame(width: UIScreen.main.bounds.size.width * (songTime / song.playbackDuration),
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
            .padding(.leading)
            .padding(.trailing)
        }
        .frame(width: UIScreen.main.bounds.size.width, height: 60)
        .background(Color(UIColor.systemGray6))
        .onTapGesture {
            if viewModel.applicationState == .queueOwner {
                viewModel.isPlayerViewPresented = true
            }
        }
        .onReceive(viewModel.timer) { _ in
            Task {
                await viewModel.checkCurrentlyPlayingSong()
                await MainActor.run {
                    songTime = viewModel.musicPlayer.currentPlaybackTime
                }
            }
        }
    }
}
