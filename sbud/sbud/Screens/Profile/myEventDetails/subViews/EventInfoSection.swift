//
//  EventInfoSection.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct EventInfoSection: View {
    let title: String
    let activityType: ActivityType         
    let activityDetails: ExtraArgsHolder
    let notes: String?
    let dateLocations: [DateLocationEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.title)
                    .foregroundColor(.white)
                    .italic()
                    .padding(.horizontal)
                Spacer()
            }

            ViewActivityTypeForDetails(activityType: activityType)
                .padding(.bottom, 10)
            PerformanceTargetDetailedConditional(activityDetails: activityDetails)

            GenericMultilineTextView(
                fieldName: "Description",
                placeholder: "Ex: Come join us",
                iconString: "pencil",
                text: notes ?? ""
            )

            LocationMapCard(dateLocations: dateLocations)
                .padding()
        }
    }
}
//#Preview {
//    EventInfoSection()
//}
