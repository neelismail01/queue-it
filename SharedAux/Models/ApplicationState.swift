//
//  ApplicationState.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-23.
//

import Foundation

enum ApplicationState {
    case loadingApplication
    case unauthorized
    case readyForQueue
    case queueOwner
    case queueContributor
}
