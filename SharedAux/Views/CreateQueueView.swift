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
        VStack {
            TextField("Name your queue",text: $queueName)
                .padding(.all, 10)
                .frame(height: 50)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .font(.system(size: 16))
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.createFirebaseQueue(queueName: queueName)
                }
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(5)
                    .font(.system(size: 16, weight: .bold))
            }
            .disabled(queueName.isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Create Queue")
    }
}
