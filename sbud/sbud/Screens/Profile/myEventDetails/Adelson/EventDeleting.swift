//
//  EventDelete.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
protocol EventDeleting {
    func deleteEvent(eventId: String) async throws
}
extension DeleteEventRequester: EventDeleting {}
