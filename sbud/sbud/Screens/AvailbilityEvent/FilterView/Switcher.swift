//
//  Switcher.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct Switcher: View {
    var optionsNames = ["Football", "Running", "Basketball", "Volleyball"]
    var optionsIcons = ["figure.australian.football","figure.run", "figure.basketball", "figure.volleyball"]
    var chosenIndex = 0
    
    var body: some View {
        VStack{
            Image(systemName: optionsIcons[chosenIndex])
                .font(.system(size: 220))
            Text(optionsNames[chosenIndex])
                .font(.system(size: 40))
        }
        
    }
}

#Preview {
    Switcher()
}
