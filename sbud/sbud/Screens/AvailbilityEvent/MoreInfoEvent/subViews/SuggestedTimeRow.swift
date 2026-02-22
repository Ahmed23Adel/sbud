//
//  SuggestedTimeRow.swift
//  sbud
//
//  Created by ahmed on 05/02/2026.
//

import SwiftUI
import Lottie

struct SuggestedTimeRow: View {
    var startDate: Date
    var endDate: Date
    var lottieFileWidth: CGFloat =  80
    var lottieFileHeight: CGFloat =  90
    
    var body: some View {
        HStack{
            Spacer()
            // MARK: Start Date
            TimeCard(date: startDate, title: "Start time")
            // MARK: End Date
            TimeCard(date: endDate, title: "End time")
            Spacer()
        }
    }
}

// MARK: - Reusable Time Card Component
struct TimeCard: View {
    var date: Date
    var title: String
    
    var body: some View {
        VStack{
            HStack{
                LottieView(animation: .named("Calendar"))
                    .playing()
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipped()
                    .padding(6)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.mainColor)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Group{
                Text(date, format: .dateTime.day().month().year())
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                Text(date, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
        .frame(width: UIConstants.smallCardWidth)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .fill(Color.backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .stroke(Color.mainColor, lineWidth: 0.5)
        )
        .popUp()
        .onTapGesture{
            PopUpGenerator.shared.show(msg: "Propsed available time range", type: .information)
        }
    }
}

#Preview {
    SuggestedTimeRow(startDate: Date(), endDate: Date())
}
