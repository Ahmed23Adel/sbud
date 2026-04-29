//
//  UserCardVM.swift
//  sbud
//
//  Created by Erdal on 14.04.2026.
//

import Foundation
import Combine

@MainActor
final class UserCardVM: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var eventDetails: EventFullDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let eventRequester = EventByIdRequester()

    func fetchUser(userId: String) async {
        guard !userId.isEmpty else { return }
        do {
            userProfile = try await ProfileManager.shared.getProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchEventDetails(eventId: String) async {
        guard !eventId.isEmpty else { return }
        do {
            eventDetails = try await eventRequester.fetchEvent(eventId: eventId)
        } catch {
        }
    }

    func displayName(fallback: String) -> String {
        if let profile = userProfile, !profile.name.isEmpty {
            let lastInitial = profile.surName.first.map { "\($0)." } ?? ""
            return "\(profile.name) \(lastInitial)".trimmingCharacters(in: .whitespaces)
        }
        return fallback
    }

    var metrics: [(label: String, value: String)] {
        guard let args = eventDetails?.activityDetails.extraArgs else { return [] }

        switch args {
        case let r as ExtraArgsHolderRunning:
            return [
                ("DISTANCE", String(format: "%.1f KM", r.proposedDistance)),
                ("PACE", formatPace(r.proposedPace))
            ]
        case let c as ExtraArgsHolderCycling:
            return [
                ("POWER", String(format: "%.0f W", c.proposedPowerInWatt)),
                ("CADENCE", String(format: "%.0f RPM", c.proposedCadenceInRPM))
            ]
        case let g as ExtraArgsHolderGym:
            return [
                ("DAY TYPE", g.proposedDayType.rawValue.uppercased())
            ]
        case let s as ExtraArgsHolderSkiing:
            return [
                ("SPEED", String(format: "%.0f KM/H", s.proposedSpeedInKmH)),
                ("VERT. DROP", String(format: "%.0f M", s.proposedVerticalDropInM))
            ]
        case let sw as ExtraArgsHolderSwimming:
            return [
                ("DISTANCE", String(format: "%.0f M", sw.proposedDistanceInM)),
                ("PACE", String(format: "%.1f /100M", sw.proposedPacePer100M))
            ]
        case let h as ExtraArgsHolderHiking:
            return [
                ("DISTANCE", String(format: "%.1f KM", h.proposedDistanceInKm)),
                ("ELEV. GAIN", String(format: "%.0f M", h.proposedElevationGainInM))
            ]
        case let y as ExtraArgsHolderYoga:
            return [
                ("DURATION", String(format: "%.0f MIN", y.proposedDurationInMin)),
                ("INTENSITY", "LVL \(Int(y.proposedIntensityLevel))")
            ]
        case let t as ExtraArgsHolderTennis:
            return [
                ("SETS", String(format: "%.0f SETS", t.proposedSets)),
                ("DURATION", String(format: "%.0f MIN", t.proposedDurationInMin))
            ]
        default:
            return []
        }
    }

    private func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02dKM/H", minutes, seconds)
    }
}
