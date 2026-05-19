//
//  Split.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation

struct Split: Identifiable, Codable {
    var id = UUID()
    let number: Int
    let paceInMinPerKm: Double
    let dateTimeCreated = Date()

    var formatted: String {
        let mins = Int(paceInMinPerKm)
        let secs = Int((paceInMinPerKm - Double(mins)) * 60)
        return String(format: "%d'%02d\"/km", mins, secs)
    }
}
