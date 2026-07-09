//
//  EventMetaBadgesRow.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct EventMetaBadgesRow: View {
    let isDateConfirmed: Bool
    let isLocationConfirmed: Bool
    let joinCondition: JoinCondition     
    let isPublic: Bool
    let maxAllowedToJoin: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProposalVsDeterminedPhase(
                isDateConfirmed: isDateConfirmed,
                isLocationConfirmed: isLocationConfirmed
            )

            FlowLayout(spacing: 8) {
                JoiningProtocolDetailed(joiningProtocol: joinCondition)
                VisibilityDetailed(isPublic: isPublic)
                if let max = maxAllowedToJoin {
                    CapacityBadge(max: max)
                }
            }
            .padding(.leading, 14)
        }
    }
}
//
//#Preview {
//    EventMetaBadgesRow()
//}
