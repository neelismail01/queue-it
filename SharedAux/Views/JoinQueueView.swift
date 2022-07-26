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
                .padding(.all, 10)
                .frame(height: 50)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .font(.system(size: 16))
                .submitLabel(.join)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.joinFirebaseQueue(joinCode: joinCode)
                }
            } label: {
                Text("Join")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(5)
                    .font(.system(size: 16, weight: .bold))
            }
            .disabled(joinCode.isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Join Queue")
    }
}
