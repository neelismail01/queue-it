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
            Spacer()
            Text("Open Settings to grant Shared Aux access to your Apple Music")
                .foregroundColor(.primary)
                .font(.system(size: 16, weight: .light))
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: handleButtonPressed) {
                Text("Open Settings")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func handleButtonPressed() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            openURL(settingsURL)
        }
    }
}

