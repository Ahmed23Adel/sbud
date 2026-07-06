//
//  HomeViewModel.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation
import OSLog
import CoreLocation
import SwiftUI

@Observable
class HomeViewModel: NSObject, CLLocationManagerDelegate {
    var upcomingEvents: [UpcomingEvent] = []
    var recommendedEvents: [RecommendedEvent] = []
    var friendsActivity: [FriendActivityItem] = []
    var meetPeople: [MeetPersonItem] = []
    var privateEvents: [PrivateEvent] = []
    var isLoading = false

    private var userLocation: CLLocation?
    private let locationManager = CLLocationManager()
    private let cache = RecommendedEventsCache.shared
    let logger = Logger(subsystem: "sbud", category: "HomeViewModel")

    // MARK: - Dependencies (test seams)

    private let homeDataFetcher: HomeDataFetching
    private let joinRequester: JoinEventRequesting

    init(
        homeDataFetcher: HomeDataFetching = HomeRequester(),
        joinRequester: JoinEventRequesting = JoinEventRequester(),
        autoStart: Bool = true
    ) {
        self.homeDataFetcher = homeDataFetcher
        self.joinRequester = joinRequester
        super.init()
        guard autoStart else { return }
        isLoading = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if let cached = cache.load() { recommendedEvents = cached }
        Task { await load() }
    }

    func load() async {
        await MainActor.run { isLoading = true }
        do {
            let lat = userLocation?.coordinate.latitude
            let lon = userLocation?.coordinate.longitude
            let response = try await homeDataFetcher.fetchHome(lat: lat, lon: lon)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.4)) {
                    upcomingEvents = response.upcoming
                    meetPeople = response.meetPeople
                    privateEvents = response.privateEvents
                    isLoading = false
                }
                withAnimation(.easeOut(duration: 0.35)) {
                    friendsActivity = response.friendsActivity
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    recommendedEvents = response.recommended
                }
                cache.save(response.recommended)
            }
        } catch {
            logger.error("load error: \(error)")
            await MainActor.run { isLoading = false }
        }
    }

    func joinEvent(eventId: String) async {
        do {
            let resp = try await joinRequester.joinEvent(eventId: eventId)
            await MainActor.run {
                switch resp.status {
                case "confirmed": PopUpGenerator.shared.show(msg: "You have joined the event!", type: .notification)
                case "pending": PopUpGenerator.shared.show(msg: "Request sent, awaiting approval.", type: .notification)
                case "waitlisted": PopUpGenerator.shared.show(msg: resp.message, type: .information)
                default: break
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    if let idx = recommendedEvents.firstIndex(where: { $0.eventId == eventId }) {
                        recommendedEvents[idx].userStatus = resp.status
                    }
                }
                Task { await self.load() }
            }
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("Location error: \(error)")
    }
}
