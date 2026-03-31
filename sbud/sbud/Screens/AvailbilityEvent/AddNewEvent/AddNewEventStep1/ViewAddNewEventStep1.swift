//
//  ViewAddNewEventStep1.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import SwiftUI

struct ViewAddNewEventStep1: View {
    @Bindable var eventBuilder: NewEventBuilder
    var body: some View {
        Text("step1")
    }
}

#Preview {
    ViewAddNewEventStep1(eventBuilder: NewEventBuilder())
}
