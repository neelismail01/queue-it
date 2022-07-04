//
//  QueueControlView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-03.
//

import SwiftUI

struct QueueControlView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: SearchView()) {
                Text("Add a song")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
