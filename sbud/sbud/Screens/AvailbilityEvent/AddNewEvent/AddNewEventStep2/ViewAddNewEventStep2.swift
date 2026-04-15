//
//  ViewAddNewEventStep2.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import SwiftUI

struct ViewAddNewEventStep2: View {
    @Bindable var eventBuilder: NewEventBuilder
    var body: some View {
        ZStack{
            Color.darkBackground
                .ignoresSafeArea()
            ScrollView{
                VStack{
                    ViewDateLocationAdder(objsDateLocations: eventBuilder.dateLocationsHolder)
                        .padding(.top, 100)
                    VisibilitySelector(isPublic: $eventBuilder.isEventPublic)
                        .padding(.bottom, 100)
                }
            }
        }
        .ignoresSafeArea(.container)
    }
}

#Preview {
    ViewAddNewEventStep2(eventBuilder: NewEventBuilder())
}
