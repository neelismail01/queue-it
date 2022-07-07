//
//  JoinQueueView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-03.
//

import SwiftUI

struct JoinQueueView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var joinCode = ""
    
    var body: some View {
        VStack {
            TextField("Enter a code", text: $joinCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .submitLabel(.join)
                .onSubmit {
                    Task {
                        await viewModel.joinFirebaseQueue(joinCode: joinCode)
                    }
                }
        }
    }
}
