//
//  PlaybackFullScreenView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-25.
//

import SwiftUI

struct PlaybackFullScreenView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State var songTime = 0.0
    @State private var isEditing = false
    
    let screenWidth = UIScreen.main.bounds.size.width - 40
        
    var albumArt: some View {
        Group {
            if let activeQueue = viewModel.activeQueue,
               let songIndex = viewModel.activeQueue?.currentSongIndex,
               songIndex < activeQueue.songAdditions.count {
                
                let currentSong = activeQueue.songAdditions[songIndex]
                
                AlbumImage(frameWidth: screenWidth,
                           frameHeight: screenWidth,
                           url: URL(string: currentSong.songArtworkUrlLarge))
                
            } else {
                AlbumImage(frameWidth: screenWidth,
                           frameHeight: screenWidth,
                           url: nil)
            }
        }
    }
    
    var songDetails: some View {
        VStack {
            if let activeQueue = viewModel.activeQueue,
               let songIndex = viewModel.activeQueue?.currentSongIndex {
                
                let currentSong = activeQueue.songAdditions[songIndex]
                
                VStack {
                    Text(currentSong.songName)
                        .font(.system(size: 24, weight: .semibold))
                        .lineLimit(1)
                    Text(currentSong.songArtist)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            } else {
                Text("Not Playing")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 10)
    }
    
    var slider: some View {
        let song = viewModel.musicPlayer.nowPlayingItem
        
        return Slider(value: $songTime,
               in: 0...(song?.playbackDuration ?? 0.0)) { editing in
            isEditing = editing
            if !editing {
                viewModel.musicPlayer.currentPlaybackTime = songTime
            }
        }
    }
    
    var timeIndicators: some View {
        let song = viewModel.musicPlayer.nowPlayingItem
        let musicPlayer = viewModel.musicPlayer

        return HStack {
            let currentPlaybackTime = musicPlayer.currentPlaybackTime
            let songLength = song?.playbackDuration ?? 0.0
            
            let songPlayedMinuteValue = Int((currentPlaybackTime / 60).rounded(.towardZero))
            let songPlayedSecondValue = Int(currentPlaybackTime.truncatingRemainder(dividingBy: 60))
            let formattedPlayedSecondValue = String(format: "%02d", songPlayedSecondValue)
            
            let songRemaining = songLength - currentPlaybackTime
            let songRemainingMinuteValue = Int((songRemaining / 60).rounded(.towardZero))
            let songRemainingSecondValue = Int(songRemaining.truncatingRemainder(dividingBy: 60))
            let formattedRemainingSecondValue = String(format: "%02d", songRemainingSecondValue)
            
            Text("\(songPlayedMinuteValue):\(formattedPlayedSecondValue)")
                .font(.system(size: 10))
            Spacer()
            Text("\(songRemainingMinuteValue):\(formattedRemainingSecondValue)")
                .font(.system(size: 10))
        }
    }
    
    var songTimelineSlider: some View {
        VStack {
            slider
            timeIndicators
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    var playbackControls: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.goToPreviousSong()
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 24))
            }
            .disabled(viewModel.musicPlayer.nowPlayingItem == nil)

            Spacer()
            
            Button {
                if viewModel.isSongPlaying {
                    viewModel.musicPlayer.pause()
                } else {
                    viewModel.musicPlayer.play()
                }
            } label: {
                if viewModel.isSongPlaying {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 64))
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 64))
                }
            }
            .disabled(viewModel.musicPlayer.nowPlayingItem == nil)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.goToNextSong()
                }
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 24))
            }
            .disabled(viewModel.musicPlayer.nowPlayingItem == nil)
            
            Spacer()
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 10)
    }
    
    
    var body: some View {
        VStack {
            albumArt
            songDetails
            songTimelineSlider
            playbackControls
        }
        .padding(20)
        .frame(alignment: .top)
        .onReceive(viewModel.checkSongTimer) { _ in
            if !isEditing {
                Task {
                    await MainActor.run {
                        songTime = viewModel.musicPlayer.currentPlaybackTime
                    }
                }
            }
        }
    }
}
