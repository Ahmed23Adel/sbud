//
//  JoinEventButton.swift
//  sbud
//
//  Created by Erdal on 3.05.2026.
//

import SwiftUI

struct JoinEventButton: View {
    let joinCondition: JoinCondition
    let joinState: JoinState
    let isLoading: Bool
    let onJoin: () -> Void
    let onWithdraw: () -> Void
    let onLeave: () -> Void

    var body: some View {
        VStack(spacing: 8) {

            Button(action: onJoin) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Image(systemName: joinState.iconName)
                            .font(.system(size: 15, weight: .semibold))
                        Text(joinButtonLabel)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(buttonColor)
                .foregroundColor(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                .animation(.easeInOut(duration: 0.2), value: joinState)
            }
            .disabled(isLoading || joinState.isDisabled)

            if joinState.canWithdraw {
                Button(action: onWithdraw) {
                    Text("Withdraw Request")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .underline()
                }
            }

            if joinState.canLeave {
                Button(action: onLeave) {
                    Text("Leave Event")
                        .font(.system(size: 13))
                        .foregroundColor(.red.opacity(0.8))
                        .underline()
                }
            }
        }
        .padding(.horizontal)
    }

    private var joinButtonLabel: String {
        switch joinState {
        case .idle:
            return joinCondition == .autoJoin ? "Join Activity" : "Request to Join"
        case .withdrawn, .rejected:
            return joinCondition == .autoJoin ? "Join Again" : "Request Again"
        case .pending:
            return "Pending Approval"
        case .waitlisted:
            return "Waitlisted"
        case .confirmed:
            return "Joined"
        case .full:
            return "Event Full"
        }
    }

    private var buttonColor: Color {
        switch joinState {
        case .idle, .withdrawn, .rejected: return Color.mainColor
        case .confirmed:                   return Color(red: 0, green: 227/255, blue: 253/255)
        case .pending:                     return Color.backgroundColor
        case .waitlisted:                  return Color.backgroundColor.opacity(0.7)
        case .full:                        return Color.gray.opacity(0.35)
        }
    }

    private var foregroundColor: Color {
        switch joinState {
        case .idle, .withdrawn, .rejected, .confirmed: return .black
        default: return .white
        }
    }
}
