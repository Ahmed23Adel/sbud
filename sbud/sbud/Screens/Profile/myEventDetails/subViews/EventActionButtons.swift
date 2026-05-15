//
//  EventActionButtons.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//
import SwiftUI

struct EventActionButtons: View {
    let eventId: String
    let eventTitle: String
    let isDateConfirmed: Bool
    let isLocationConfirmed: Bool
    let queueResponse: JoinQueueResponse?   
    let onConfirmTap: () -> Void
    let onMessagesTap: () -> Void
    let onHostsTap: () -> Void
    let onQueueTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if !isDateConfirmed || !isLocationConfirmed {
                confirmButton
            }
            messagesButton
            hostsButton
            queueButton
        }
    }

    // MARK: - Private

    private var confirmButton: some View {
        Button(action: onConfirmTap) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                Text("Confirm Final Details")
            }
        }
        .buttonStyle(PrimaryButton())
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private var messagesButton: some View {
        Button(action: onMessagesTap) {
            HStack(spacing: 12) {
                Image(systemName: "tray.fill")
                    .font(.system(size: 20))
                Text("View Messages")
            }
            
        }
        .buttonStyle(PrimaryButton())
    }

    private var hostsButton: some View {
        Button(action: onHostsTap) {
            HStack(spacing: 10) {
                Image(systemName: "person.2.wave.2")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(.black)
                Text("Invite/Edit hosts")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(Capsule().fill(Color("palelime")))
        }
        .buttonStyle(PrimaryButton())
    }

    private var queueButton: some View {
        let pendingCount = queueResponse?.pendingCount ?? 0
        let waitlistCount = queueResponse?.waitlistCount ?? 0
        let hasPending = pendingCount > 0

        return Button(action: onQueueTap) {
            HStack(spacing: 10) {
                Image(systemName: "person.badge.clock")
                    .font(.system(size: 15, weight: .semibold))
                Text(queueButtonLabel(pending: pendingCount, waitlist: waitlistCount))
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(hasPending ? Color.mainColor : Color.backgroundColor.opacity(0.5))
            .foregroundColor(hasPending ? .black : .white)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    private func queueButtonLabel(pending: Int, waitlist: Int) -> String {
        guard pending > 0 else { return "No Pending Requests" }
        let waitlistSuffix = waitlist > 0 ? ", \(waitlist) waitlist" : ""
        return "Review Requests (\(pending) pending\(waitlistSuffix))"
    }
}

