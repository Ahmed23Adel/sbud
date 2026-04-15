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
                .ignoresSafeArea()
            ScrollView{
                VStack{
                    ViewEventImageSelection(eventBuidler: eventBuilder)
                        .padding(.top, 100)
                    
                    GenericTextInputView(
                        fieldName: "Title",
                        placeholder: "Ex: Midnight Runners",
                        iconString: "text.rectangle",
                        text: $eventBuilder.title)
                    
                    GenericMultilineTextInputView(
                        fieldName: "Description",
                        placeholder: "Ex: Come join us",
                        iconString: "pencil",
                        text: $eventBuilder.description)
                    
                    ActivityTypeSelector(selectedActivityType: $eventBuilder.activityType, extraArgsHolder: $eventBuilder.activityExtraArgs)
                    
                    ViewConditionalExtraArgs(argsHolder: eventBuilder.activityExtraArgs)
                        .padding(.bottom, 100)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {                                    // ← Single toolbar here
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("✓") {
                        // UIKIT organizes the views
                        // first responder is the one that has focus now
                        // to dismiss, whoever the first responder is, resign
                        // UIApplication.shared: running instance of app
                        // #selector(UIResponder.resignFirstResponder) — the action to perform.
                        // to: nil — the target. nil means "don't send it to a specific object" — instead, walk the responder chain and let whoever can handle it respond
                        // from: nil — the sender. Who is triggering this action. nil means anonymous/unspecified
                        UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
                    }
                }
            }
        }
        //only ignores edge insets (notch/home bar)
        // otherwise, it will ignore the keyboard as well
//        .ignoresSafeArea(.container)
    }
}

#Preview {
    ViewAddNewEventStep1(eventBuilder: NewEventBuilder())
}
