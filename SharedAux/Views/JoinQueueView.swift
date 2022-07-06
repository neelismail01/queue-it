//
//  JoinQueueView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-03.
//

import SwiftUI

struct JoinQueueView: View {
    @State private var score = 0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            TextField("Enter your score", value: $score, formatter: formatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Your score was \(score).")
        }
    }
}
