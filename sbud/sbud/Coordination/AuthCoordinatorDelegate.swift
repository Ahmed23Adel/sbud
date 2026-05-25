//
//  AuthCoordinatorDelegate.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import Foundation

//  Delegate protocols that child coordinators use to communicate
//  upward to MainCoordinator — without importing or referencing it directly.
//

import Foundation

// MARK: - Main App Level Delegates

/// Any coordinator that needs to trigger app-level auth changes conforms to this.
protocol AuthCoordinatorDelegate: AnyObject {
    func coordinatorDidRequestLogout()
    func coordinatorDidCompleteSignIn()
    func coordinatorDidCompleteProfileSetup()
}

/// Session-level delegate — used by session views to return to home.
protocol SessionCoordinatorDelegate: AnyObject {
    func sessionDidEnd()
}
