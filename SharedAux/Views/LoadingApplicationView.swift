//
//  LoadingApplicationView.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-17.
//

import SwiftUI

struct LoadingApplicationView: View {
    var body: some View {
        Text("Shared Aux")
            .font(.system(size: 40, weight: .bold))
            .padding(2.5)
        Text("Curate Music Together")
            .font(.system(size: 16, weight: .light))
    }
}

struct LoadingApplicationView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingApplicationView()
    }
}
