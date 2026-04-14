//
//  ViewAddNewEventStep1.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import SwiftUI
import Kingfisher
struct ViewAddNewEventStep1: View {
    @Bindable var eventBuilder: NewEventBuilder
    var body: some View {
        ZStack{
            Color.darkBackground
            ScrollView{
                VStack{
                    ViewEventImageSelection(eventBuidler: eventBuilder)
                        .padding(.top, 100)
                    
                    GenericTextInputView(
                        fieldName: "Title",
                        placeholder: "Ex: Midnight Runners",
                        iconString: "text.rectangle",
                        text: $eventBuilder.title)
                    
                    ActivityTypeSelector(selectedActivityType: $eventBuilder.activityType)
                }
                
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ViewAddNewEventStep1(eventBuilder: NewEventBuilder())
}
