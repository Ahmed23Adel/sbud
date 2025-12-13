//
//  SecondaryButton.swift
//  sbud
//
//  Created by ahmed on 13/12/2025.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveSecondaryButtonStyle() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
                .tint(Color.mainColor)
                .buttonBorderShape(.capsule)
        }
    }
}
