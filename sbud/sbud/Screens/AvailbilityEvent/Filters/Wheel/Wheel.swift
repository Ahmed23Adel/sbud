//
//  Wheel.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct Wheel: View {
    
    @State private var currentRotation: Double = 0
    @State private var lastRotation: Double = 0
    // @ gestureState
    // The value is updated during the gesture
    // When the gesture finishes or is cancelled, SwiftUI resets it back to 0 automatically
    @GestureState private var dragRotation: Double = 0
    
    // Minimum drag threshold in degrees to trigger rotation
    let rotationThreshold: Double = 45.0
    
    var body: some View {
        RadialLinesView()
            .rotationEffect(Angle(degrees: currentRotation + dragRotation))
            .gesture(
                DragGesture()
                    // note that state binds to $dragRotation
                    .updating($dragRotation) { value, state, _ in
                        let angle = calculateAngle(from: value.translation)
                        state = angle
                    }
                    .onEnded { value in
                        // when user lifts their finger
                        let dragAngle = calculateAngle(from: value.translation)
                        let totalRotation = lastRotation + dragAngle
                        
                        // Check if drag exceeded threshold
                        if abs(dragAngle) >= rotationThreshold {
                            // Strong enough drag - snap to nearest 90°
                            // Snap to nearest 90-degree increment
                            // for example
                            // Divide by 90: 185 / 90 = 2.055
                            // Round to nearest integer: round(2.055) = 2
                            // Multiply back by 90: 2 × 90 = 180°
                            let snappedRotation = round(totalRotation / 90.0) * 90.0
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentRotation = snappedRotation
                                lastRotation = snappedRotation
                            }
                        } else {
                            // Weak drag - return to previous position
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentRotation = lastRotation
                            }
                        }
                    }
            )
    }
    
    func calculateAngle(from translation: CGSize) -> Double {
        // converts horizontal distance to radial rotation
        // If you drag 100 pixels right: 100 × 0.5 = 50° rotation
        // Support both horizontal and vertical drags for more natural rotation
        let dx = translation.width
        let dy = translation.height
        
        // Use primarily horizontal movement, but allow vertical to contribute
        let angle = dx * 0.5 - dy * 0.2
        
        return angle
    }
}

#Preview {
    Wheel()
}
