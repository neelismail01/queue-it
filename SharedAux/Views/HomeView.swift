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
        VStack {
            Spacer()
            Text("Shared Aux")
                .font(.system(size: 40, weight: .bold))
                .padding(2.5)
            Text("Curate Music Together")
                .font(.system(size: 16, weight: .light))
            Spacer()
            NavigationLink(destination: CreateQueueView()) {
                Text("Create a Queue")
                    .fontWeight(.bold)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(5)
            }
            NavigationLink(destination: JoinQueueView()) {
                Text("Join a Queue")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
