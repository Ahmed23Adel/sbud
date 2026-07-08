//
//  HostingEventFetching.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
protocol HostingEventsFetching {
    func fetchHostingEvents() async throws -> [HostingEvent]
}
extension HostingEventsRequester: HostingEventsFetching {}
