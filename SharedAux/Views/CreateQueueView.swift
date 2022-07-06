//
//  CreateQueueView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-18.
//

import SwiftUI

struct CreateQueueView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State var queueName = ""
    
    var body: some View {
        VStack() {
            TextField("Name your queue", text: $queueName)
            Spacer()
            NavigationLink(destination: QueueControlView()) {
                Text("Continue")
                    .onTapGesture {
                        Task {
                            await viewModel.createFirebaseQueue(nameOfQueue: queueName)
                        }
                    }
                    .disabled(queueName.isEmpty)
            }
        }
        .navigationTitle("Create A Queue")
        .padding()
    }
}
