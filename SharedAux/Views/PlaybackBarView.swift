//
//  PlaybackBarView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-24.
//

import SwiftUI

struct PlaybackBarView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var albumImage: some View {
        let currentSong = viewModel.currentlyPlayingItem
        
        return Image(uiImage: (currentSong?.artwork?.image(at: CGSize(width: 50, height: 50))!)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
    }
    
    var albumImagePlaceholder: some View {
        Image(systemName: "music.note")
            .frame(width: 50, height: 50, alignment: .center)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
    }
    
    var body: some View {
        let currentSong = viewModel.currentlyPlayingItem

        VStack() {
            Spacer(minLength: 0)
            HStack {
                if currentSong != nil {
                    if currentSong?.artwork != nil {
                        albumImage
                    } else {
                        albumImagePlaceholder
                    }
                    VStack(alignment: .leading) {
                        Text(currentSong?.title ?? "Unknown Song")
                            .font(.system(size: 16, weight: .semibold))
                        Text(currentSong?.artist ?? "Unknown Artist")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.gray)
                    }
                } else {
                    albumImagePlaceholder
                    Text("Not Playing")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if currentSong == nil {
                    Image(systemName: "play.fill")
                        .padding()
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                } else if viewModel.isSongPlaying {
                    Button {
                        print("supposed to be true: \(viewModel.isSongPlaying)")
                        viewModel.musicPlayer.pause()
                        viewModel.isSongPlaying = false
                    } label: {
                        Image(systemName: "pause.fill")
                            .padding()
                            .font(.system(size: 22))
                    }
                } else {
                    Button {
                        print("supposed to be false: \(viewModel.isSongPlaying)")
                        viewModel.musicPlayer.play()
                        viewModel.isSongPlaying = true
                    } label: {
                        Image(systemName: "play.fill")
                            .padding()
                            .font(.system(size: 22))
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.size.width, height: 65, alignment: .leading)
            .foregroundColor(.black)
            .background(.white)
            .onTapGesture {
                viewModel.isPlayerViewPresented = true
            }
        }
        .onReceive(viewModel.timer) { _ in
            viewModel.checkCurrentlyPlayingSong()
        }
    }
}
