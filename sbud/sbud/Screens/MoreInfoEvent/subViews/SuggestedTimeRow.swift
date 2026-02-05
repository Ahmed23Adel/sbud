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
            VStack{
                HStack{
                    LottieView(animation: .named("Calendar"))
                        .playing()
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipped()
                    Text("Start time")
                        .font(.headline)
                        .foregroundColor(Color.mainColor)
                        .multilineTextAlignment(.center)
                    Spacer()
                    
                }
                Group{
                    Text(startDate, format: .dateTime.day().month().year())
                        .font(.headline)
                        .foregroundColor(Color.white)
                    
                    Text(startDate, format: .dateTime.hour().minute())
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                .padding(.horizontal)
            }
            .frame(width: UIConstants.cardWidth)
            .padding(4)
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
            Spacer()
            // MARK: End Date
            VStack{
                HStack{
                    LottieView(animation: .named("Calendar"))
                        .playing()
                        .frame(width: 40, height: 40)
                    Text("End time")
                        .font(.headline)
                        .foregroundColor(Color.mainColor)
                        .multilineTextAlignment(.center)
                    
                }
                Group{
                    Text(endDate, format: .dateTime.day().month().year())
                        .font(.headline)
                        .foregroundColor(Color.white)
                    
                    Text(endDate, format: .dateTime.hour().minute())
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            .frame(width: UIConstants.cardWidth)
            .padding(4)
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
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SuggestedTimeRow(startDate: Date(), endDate: Date())
}
