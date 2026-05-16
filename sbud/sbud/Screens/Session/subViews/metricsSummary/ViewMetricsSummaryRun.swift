//
//  ViewMetricsSummaryRun.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI

struct ViewMetricsSummaryRun: View {
    var collector: MetricsCollectorRun
    
    var body: some View {
        VStack{
            HStack{
                Text("Total Distance: ")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                
                Text(String(format: "%.0f", collector.totalDistanceMeters))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                
                Spacer()
                Text("m")
                    .foregroundColor(.gray)
            }
            .padding()
            
            HStack{
                Text("Current Pace: ")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                
                Text(String(format: "%.2f", collector.currentPaceMinPerKm))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                
                Spacer()
                Text("min/KM")
                    .foregroundColor(.gray)
            }
            .padding()
            
            HStack{
                Text("Average Pace: ")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                
                Text(String(format: "%.2f", collector.averagePaceMinPerKm))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                
                Spacer()
                Text("min/KM")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        
    }
    
    
}


//#Preview {
//    ViewMetricsSummaryRun()
//}
