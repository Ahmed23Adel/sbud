//
//  ViewEventSummary.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI

struct ViewEventSummary: View {
    let event: EventFullDetails
    
    var body: some View {
        VStack{
            Text(event.title)
                .foregroundColor(Color.mainColor)
                .font(.system(size: 44))
                .lineLimit(2)
                .padding(.vertical)
            
            Image(systemName: event.activityType.icon)
                .foregroundColor(Color.mainColor)
                .font(.title)
            
            
        }
        .padding()
    }
}

//#Preview {
//    ViewEventSummary()
//}
