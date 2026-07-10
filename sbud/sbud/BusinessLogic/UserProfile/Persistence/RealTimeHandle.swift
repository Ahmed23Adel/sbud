//
//  RealTimeHandle.swift
//  sbud
//
//  Created by Erdal on 10.07.2026.
//

import Foundation
import FirebaseFirestore

protocol RealtimeListenerHandle {
    func remove()
}

struct FirestoreListenerHandle: RealtimeListenerHandle {
    private let registration: ListenerRegistration

    init(_ registration: ListenerRegistration) {
        self.registration = registration
    }

    func remove() {
        registration.remove()
    }
}

struct NoOpListenerHandle: RealtimeListenerHandle {
    func remove() {}
}

struct CompositeListenerHandle: RealtimeListenerHandle {
    private let handles: [RealtimeListenerHandle]

    init(_ handles: [RealtimeListenerHandle]) {
        self.handles = handles
    }

    func remove() {
        handles.forEach { $0.remove() }
    }
}
