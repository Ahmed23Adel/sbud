//
//  FeedbackTag.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 27/05/2026.
//


import SwiftUI

struct FeedbackTag: Identifiable {
    let id = UUID()
    var name: String
    var count: Int
    var color: Color
}