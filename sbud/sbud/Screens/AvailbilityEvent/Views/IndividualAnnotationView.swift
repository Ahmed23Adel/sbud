//
//  IndividualAnnotationView.swift
//  sbud
//
//  Created by ahmed on 24/12/2025.
//

import SwiftUI

struct IndividualAnnotationView: View {
    let event: AnchorAvailabilityEvent
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "figure.run")
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 3)
            
            Text("run")
                .font(.caption2)
                .foregroundColor(.primary)
                .padding(4)
                .background(.ultraThinMaterial)
                .cornerRadius(4)
        }
    }
}
//
//#Preview {
//    IndividualAnnotationView(event: AvailabilityEvent(id: "id", geohash: "u0dnj87g", geoPoint: Geinto, notes: <#String#>))
//}
