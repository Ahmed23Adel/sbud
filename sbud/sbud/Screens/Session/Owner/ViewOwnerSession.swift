//
//  ownerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct ViewOwnerSession: View {
    @State private var viewModel: ViewModelOwnerSession
    
    init(eventId: String) {
        _viewModel = State(initialValue: ViewModelOwnerSession(eventId: eventId))
    }

    var body: some View {
        
    }
}
//
//#Preview {
//    ownerSession()
//}
