//
//  ViewConditionalExtraArgs.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewConditionalExtraArgs: View {
    @Binding var selectedActivity: ActivityType
    @Binding var extraArgs: [String: String]
    var body: some View {
        VStack{
            switch selectedActivity {
            case .running:
                ExtraArgsRunning(returnableArgs: $extraArgs)
            case .cycling:
                ExtraArgsCycling(returnableArgs: $extraArgs)
            case .gym:
                ExtraArgsGym(returnableArgs: $extraArgs)
            }
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        
        
    }
}

#Preview {
    ViewConditionalExtraArgs(selectedActivity: .constant(.running), extraArgs: .constant([:]))
}
