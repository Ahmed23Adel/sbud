//
//  NetworkMonitor.swift
//  sbud
//
//  Created by ahmed on 31/05/2026.
//

import Foundation
import Network
import OSLog

// MARK: - Protocol

/// Abstracts network reachability so `MetricsUploadRetryService` can be
/// tested with a mock instead of a real `NWPathMonitor`.
protocol NetworkMonitoring: AnyObject {
    var isConnected: Bool { get }
    /// Start observing. `onChange` is called on an arbitrary queue whenever
    /// connectivity changes — callers must dispatch to their own actor if needed.
    func startMonitoring(onChange: @escaping (Bool) -> Void)
    func stopMonitoring()
}

// MARK: - Live implementation

final class NetworkMonitor: NetworkMonitoring {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "sbud.NetworkMonitor", qos: .utility)
    private let logger = Logger(subsystem: "sbud", category: "NetworkMonitor")

    private(set) var isConnected = false

    private init() {}

    // It's Apple's modern API (from the Network framework) for observing network connectivity. Unlike the old Reachability approach, it doesn't poll — it's push-based. The OS calls your handler the moment the network path changes (wifi connects, airplane mode toggles, cellular kicks in, etc.). So there's no "check every 10 seconds" — it fires exactly when something changes and never otherwise.
    func startMonitoring(onChange: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            self?.isConnected = connected
            self?.logger.info("Network path changed — connected: \(connected)")
            onChange(connected)
        }
        monitor.start(queue: queue)
        logger.info("NetworkMonitor started")
    }

    func stopMonitoring() {
        monitor.cancel()
        logger.info("NetworkMonitor stopped")
    }
}
