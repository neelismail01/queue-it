//
//  WelcomeView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-20.
//

import SwiftUI
import MusicKit

struct WelcomeView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("Shared Aux")
                .font(.system(size: 40, weight: .bold))
                .padding(2.5)
            Text("Curate Music Together")
                .font(.system(size: 16, weight: .light))
            if let secondaryExplanatoryText = self.secondaryExplanatoryText {
                secondaryExplanatoryText
                    .foregroundColor(.primary)
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(2.5)
            }
            Spacer()
            if viewModel.musicAuthorizationStatus == .notDetermined || viewModel.musicAuthorizationStatus == .denied {
                Button(action: handleButtonPressed) {
                    buttonText
                        .font(.system(size: 16, weight: .bold))
                }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(5)
                    .padding()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var secondaryExplanatoryText: Text? {
        var secondaryExplanatoryText: Text?
        switch viewModel.musicAuthorizationStatus {
        case .denied:
            secondaryExplanatoryText = Text("Please grant Music Albums access to ")
            + Text(Image(systemName: "applelogo")) + Text(" Music in Settings.")
        default:
            break
        }
        return secondaryExplanatoryText
    }
    
    private var buttonText: Text {
        let buttonText: Text
        switch viewModel.musicAuthorizationStatus {
        case .notDetermined:
            buttonText = Text("Connect to Apple Music")
        case .denied:
            buttonText = Text("Open Settings")
        default:
            fatalError("No button should be displayed for current authorization status: \(viewModel.musicAuthorizationStatus).")
        }
        return buttonText
    }
    
    private func handleButtonPressed() {
        switch viewModel.musicAuthorizationStatus {
        case .notDetermined:
            Task {
                let musicAuthorizationStatus = await MusicAuthorization.request()
                update(with: musicAuthorizationStatus)
            }
        case .denied:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                openURL(settingsURL)
            }
        default:
            fatalError("No button should be displayed for current authorization status: \(viewModel.musicAuthorizationStatus).")
        }
    }
    
    @MainActor
    private func update(with musicAuthorizationStatus: MusicAuthorization.Status) {
        viewModel.loginWithAppleMusic(musicAuthorizationStatus)
    }
}

