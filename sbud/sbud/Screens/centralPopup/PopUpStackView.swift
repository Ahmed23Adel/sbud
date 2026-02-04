//
//  PopUpStackView.swift
//  sbud
//
//  Created by ahmed on 04/02/2026.
//

import SwiftUI

struct PopUpStackView: View {
    @StateObject private var popUpGenerator = PopUpGenerator.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(Array(popUpGenerator.popUps.enumerated()), id: \.element.id) { index, popUp in
                CentralPopup(
                    popUpInfo: popUp,
                    onDismiss: {
                        popUpGenerator.dismiss(popUp)
                    },
                    index: index
                )
                .offset(y: CGFloat(-index * 15))
                .scaleEffect(1 - CGFloat(index) * 0.05)
                .opacity(1 - Double(index) * 0.2)
                .zIndex(Double(popUpGenerator.popUps.count - index))
            }
        }
        .padding(.bottom, 50)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: popUpGenerator.popUps.count)
    }
}
