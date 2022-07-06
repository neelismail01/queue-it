//
//  SharedAuxApp.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-06-12.
//

import SwiftUI
import Firebase

@main
struct SharedAuxApp: App {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
