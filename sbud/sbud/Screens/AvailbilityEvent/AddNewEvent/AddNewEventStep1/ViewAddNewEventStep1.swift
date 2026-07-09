//
//  ViewAddNewEventStep1.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import SwiftUI
import Kingfisher

private struct ActivitySection: View {
    @Bindable var eventBuilder: NewEventBuilder
    var body: some View {
        ActivityTypeSelector(
            selectedActivityType: $eventBuilder.activityType,
            extraArgsHolder: $eventBuilder.activityExtraArgs)

        ViewConditionalExtraArgs(argsHolder: eventBuilder.activityExtraArgs)
            .padding(.bottom, 100)
            .padding(.horizontal, 15)
    }
}

struct ViewAddNewEventStep1: View {
    @Bindable var eventBuilder: NewEventBuilder
    var body: some View {
        ScrollView {
            VStack {
                ViewEventImageSelection(eventBuidler: eventBuilder)
                    .padding(.top, 30)
                    .padding(.horizontal)

                GenericTextInputView(
                    fieldName: "Title",
                    placeholder: "Ex: Midnight Runners",
                    iconString: "text.rectangle",
                    text: $eventBuilder.title)

                GenericMultilineTextInputView(
                    fieldName: "Description",
                    placeholder: "Ex: Come join us",
                    iconString: "pencil",
                    text: $eventBuilder.description,
                    accessibilityId: "addEvent.descriptionField")

                ActivitySection(eventBuilder: eventBuilder)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBackground.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundStyle(Color.mainColor)
                }
            }
        }
    }
}

#Preview {
    ViewAddNewEventStep1(eventBuilder: NewEventBuilder())
}
