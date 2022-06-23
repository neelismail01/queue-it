//
//  CreateQueueView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-18.
//

import SwiftUI

struct CreateQueueView: View {
    
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            gradient
            NavigationLink(destination: SearchView()) {
                    Text("Create A Queue")
                        .font(Font.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                        .overlay {
                            gradient
                            .mask(
                                Text("Create A Queue")
                                    .font(Font.system(size: 20, weight: .bold))
                                    .multilineTextAlignment(.center)
                            )
                        }
                            .padding()
                            .background(.white)
                            .cornerRadius(15)
            }
            
        }
    }
    
    /// Constructs a gradient to use as the view background.
    private var gradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: (130.0 / 255.0), green: (109.0 / 255.0), blue: (204.0 / 255.0)),
                Color(red: (130.0 / 255.0), green: (130.0 / 255.0), blue: (211.0 / 255.0)),
                Color(red: (131.0 / 255.0), green: (160.0 / 255.0), blue: (218.0 / 255.0))
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .flipsForRightToLeftLayoutDirection(false)
        .ignoresSafeArea()
    }
    
    private func handleButtonPressed() {
        print("clicked")
    }
}
