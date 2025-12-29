//
//  ImageCarousel.swift
//  sbud
//
//  Created by ahmed on 28/12/2025.
//

import SwiftUI

struct ImageCarousel: View {
    let imageNames: [String]
    let names: [String]
    let rotation: Double
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            // Calculate offset based on rotation
            // Each 90° rotation moves one full width
            // Positive rotation = move images right
            let offset = (rotation / 90) * width
            // Calculate the base index - which item should be centered
            // Start at index 0, each -90° moves forward one item
            let rotationSteps = -rotation / 90.0
            let baseIndex = Int(round(rotationSteps))
            
            // Get the three main items in the sequence
            let centerIndex = baseIndex
            
            ZStack {
                ForEach(Array(imageNames.enumerated()), id: \.offset){ index, name in
                    ImageItem(imageName: imageNames[index], name: names[index])
                        .offset(x: offset + width * CGFloat(index))
                    
                }
            }
            .frame(width: width, height: geometry.size.height)
        }
        .frame(height: 120)
        .clipped()
    }
}


#Preview {
    let icons = ["figure.run",
                 "figure.indoor.soccer",
                 "dumbbell"]
    let activityNames = ["Run",
                         "Football",
                         "Gym"]
    ImageCarousel(imageNames: icons,
                  names: activityNames,
                  rotation: 0.0)
}
