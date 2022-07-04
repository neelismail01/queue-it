//
//  HomeView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-03.
//

import SwiftUI
import MediaPlayer

struct HomeView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            gradient
            VStack {
                Spacer()
                NavigationLink(destination: CreateQueueView()) {
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 200, height: 200, alignment: .center)
                        Text("Create a Queue")
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                Spacer()
                NavigationLink(destination: JoinQueueView()) {
                    Text("Join a Queue")
                        .background(.white)
                        .cornerRadius(.infinity)
                }
                Spacer()
            }
        }
    }
    
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
}
