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
        let currentSong = viewModel.currentlyPlayingItem
        return VStack {
            if let song = currentSong, let songArtwork = song.artwork?.image(at: CGSize(width: screenWidth, height: screenWidth)) {
                Image(uiImage: songArtwork)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenWidth, height: screenWidth, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 28))
                    .frame(width: screenWidth, height: screenWidth, alignment: .center)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }
    
    var songDetails: some View {
        VStack {
            if let currentSong = viewModel.currentlyPlayingItem {
                VStack {
                    Text(currentSong.title ?? "Unknown Song")
                        .font(.system(size: 24, weight: .semibold))
                        .lineLimit(1)
                    Text(currentSong.artist ?? "Unknown Artist")
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
    }
    
    var songTimelineSlider: some View {
        let song = viewModel.currentlyPlayingItem
        let musicPlayer = viewModel.musicPlayer
        
        return VStack {
            Slider(value: $songTime, in: 0...(song?.playbackDuration ?? 0.0)) { editing in
                isEditing = editing
                if !editing {
                    musicPlayer.currentPlaybackTime = songTime
                }
            }
            .controlSize(.mini)
            
            HStack {
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
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    var playbackControls: some View {
        HStack {
            Spacer()
            Image(systemName: "backward.end.fill")
                .font(.system(size: 24))
            Spacer()
            if viewModel.currentlyPlayingItem == nil{
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 64))
            } else if viewModel.isSongPlaying {
                Button {
                    viewModel.musicPlayer.pause()
                    viewModel.isSongPlaying = false
                } label: {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 64))
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button {
                    viewModel.musicPlayer.play()
                    viewModel.isSongPlaying = true
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 64))
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
            Button {
                viewModel.playNextSong()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 24))
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            albumArt
            songDetails
            songTimelineSlider
            playbackControls
        }
        .padding()
        .onReceive(viewModel.timer) { _ in
            if !isEditing {
                viewModel.checkCurrentlyPlayingSong()
                songTime = viewModel.musicPlayer.currentPlaybackTime
            }
        }
    }
}
