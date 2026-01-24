//
//  Wheel.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI
import UIKit

struct Wheel: View {
    
    @State private var currentRotation: Double = 0
    @State private var lastRotation: Double = 0
    @GestureState private var dragRotation: Double = 0
    
    let imageNames: [String]
    let names: [String]
    @Binding var selectedIndex: Int
    
    
    @State private var wheelScale: CGFloat = 1.0
    @State private var inactivityTimer: Timer?
    private let inactivityDelay: TimeInterval = 2
    private let scaledDownSize = 0.3
    
    @State private var lastHapticIndex: Int = 0
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            // Image carousel above the wheel
            ImageCarousel(
                imageNames: imageNames,
                names: names,
                rotation: currentRotation + dragRotation
            )
            .popUp()
            .scaleEffect(wheelScale)
            .onAppear{
                startInactivityTimer()
            }
            .onDisappear{
                cancelInactivityTimer()
            }
            
            RadialLinesView()
                .onAppear {
                    if selectedIndex != 0{
                        let initialRotation = -Double(selectedIndex) * 90
                        currentRotation = initialRotation
                        lastRotation = currentRotation
                    }
                }
                .rotationEffect(Angle(degrees: currentRotation + dragRotation))
                .popUp()
                .gesture(
                    DragGesture()
                        .updating($dragRotation) { value, state, _ in
                            let angle = calculateAngle(from: value.translation)
                            let proposedRotation = lastRotation + angle
                            let clampedRotation = clampRotation(rotation: proposedRotation)
                            state = clampedRotation - lastRotation
                            triggerHapticRotation(rotation: clampedRotation)
                            scaleUpWheel()
                        }
                        .onEnded { value in
                            let dragAngle = calculateAngle(from: value.translation)
                            let totalRotation = lastRotation + dragAngle
                            let clampedRotation = clampRotation(rotation: totalRotation)
                            // Always snap to nearest 90° based on current position
                            let snappedRotation = round(clampedRotation / 90.0) * 90.0
                            let finalRotation = clampRotation(rotation: snappedRotation)
                            // Immediately update currentRotation to prevent jump when dragRotation resets to 0
                            //  You're spinning a roulette wheel
                            //  When you let go, it's at -210° (between slots)
                            //  We first "freeze" it at -210° (prevent jump)
                            //  When smoothly rotate it to -180° (nearest slot)
                            // bcz look @ ".rotationEffect(Angle(degrees: currentRotation + dragRotation))"
                            currentRotation = clampedRotation
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentRotation = finalRotation
                                lastRotation = finalRotation
                            }
                            
                            //  Converts rotation angle to "how many items forward"
                            // snappedRotation = 0° → steps = 0
                            // snappedRotation = -90° → steps = 1
                            // why -ve? Swiping left (negative rotation) moves FORWARD in the list
                            //steps = -1
                            // (-1 % 6) = -1          // First modulo: still negative
                            // -1 + 6 = 5             // Add array length: now positive
                            // 5 % 6 = 5              // Second modulo: final answer
                            let steps = Int(round(finalRotation / 90.0))
                            selectedIndex = abs(steps) // Since rotation is negative, use absolute value
                            startInactivityTimer()
                        }
                )
        }
    }
    /// Based on the movement, horizentally or vertically, it calculates the angle
    ///
    /// Plz bear in mind that dx --> +ve when swipe right, and -ve when swipe left
    /// dy --> +ve when swipe down and -ve when swipe up
    /// usually user will swipe left, dx for ex is -182, and dy 8 --> angle is  ~ -92
    private func calculateAngle(from translation: CGSize) -> Double {
        let dx = translation.width
        let dy = translation.height
        let angle = dx * 0.5 - dy * 0.2
        return angle
    }
    /// Make sure the rotation is within bounds
    private func clampRotation(rotation: Double) -> Double {
        let minRotation = Double(-(imageNames.count - 1) * 90) // can't go more right
        let maxRotation = 0.0 // can't go more left
        
        // it's neither before the minRotatin, nor is it after the maxRotation
        return max(minRotation, min(maxRotation, rotation))
    }
    
    private func startInactivityTimer(){
        cancelInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityDelay, repeats: false ){ _ in
            scaleDownWheel()
        }
    }
    
    private func cancelInactivityTimer(){
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
    
    private func scaleUpWheel() {
        // Cancel any existing timer
        cancelInactivityTimer()
        
        // Scale up if currently scaled down
        if wheelScale != 1.0 {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.57)) {
                wheelScale = 1.0
            }
        }
    }
    
    private func scaleDownWheel(){
        withAnimation(.spring(response: 0.9, dampingFraction: 0.57)) {
            wheelScale = scaledDownSize
        }
    }
    
    private func triggerHapticRotation(rotation: Double){
        let currentIndex = Int(abs(round(rotation / 10)))
        if currentIndex != lastHapticIndex {
            impactFeedback.impactOccurred(intensity: 0.5)
            lastHapticIndex = currentIndex
        }
    }
}
