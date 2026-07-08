//
//  CentralPopup.swift
//  sbud
//
//  Created by ahmed on 04/02/2026.
//

import SwiftUI
import Lottie

struct CentralPopup: View {
    @State private var isExpanded = false
    @State private var isVisible = false
    
    @ObservedObject var popUpInfo: PopUpInfo
    var onDismiss: () -> Void
    var index: Int = 0 // To know if this is the front popup
    
    var body: some View {
        ZStack {
            if isVisible {
                ZStack {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: isExpanded ? 340 : 60, height: 60)
                        .overlay(
                            Capsule()
                                .stroke(popUpInfo.type.themeColor, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 10)

                    HStack(spacing: 12) {
                        if isExpanded {
                            LottieView(animation: .named(popUpInfo.type.animationName))
                                .playing(loopMode: .playOnce)
                                .frame(width: 40, height: 40)
                            
                            Text(popUpInfo.msg)
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                                .accessibilityIdentifier("centralPopup.message")
                        }
                    }
                }
                .accessibilityIdentifier("centralPopup.container")
                .onTapGesture {
                    reverseAnimation()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        // take all the width space the parent is willing to give
        // to exactly show from the middle
        .frame(maxWidth: .infinity)
        .onAppear {
            // Only trigger animation for the front popup (index 0)
            if index == 0 {
                triggerAnimation()
            }
        }
    }

    // MARK: - Animation Logic
    private func triggerAnimation() {
        // 1. Rise up
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isVisible = true
        }
        
        // 2. Expand
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded = true
            }
        }
        
        // 3. Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            reverseAnimation()
        }
    }
    
    private func reverseAnimation() {
        guard isVisible else { return }
        
        popUpInfo.isBeingDismissed = true
        
        // 1. Shrink back to "drop" circle
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isExpanded = false
        }
        
        // 2. Drop back down off screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = false
            }
            
            // 3. Notify parent to remove from array
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onDismiss()
            }
        }
    }
}
