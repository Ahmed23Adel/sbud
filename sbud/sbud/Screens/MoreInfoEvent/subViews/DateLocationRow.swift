//
//  DateLocationRow.swift
//  sbud
//
//  Created by ahmed on 04/02/2026.
//

import SwiftUI
import Lottie

struct DateLocationRow: View {
    var cardWidth: CGFloat = UIConstants.cardWidth
    var cardHeight: CGFloat = UIConstants.cardHeight
    var lottieFileWidth: CGFloat =  80
    var lottieFileHeight: CGFloat =  90
    var isDateConfirmed: Bool
    var isLocationConfirmed: Bool
    var body: some View {
        HStack{
            // MARK: Date
            Spacer()
            if isDateConfirmed{
                ZStack{
                    HStack{
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                        LottieView(animation: .named("Calendar"))
                            .playing()
                            .frame(width: lottieFileWidth, height: lottieFileHeight)
                        
                    }
                    .frame(width: cardWidth, height: cardHeight)
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
                        PopUpGenerator.shared.show(msg: "The date is confirmed", type: .information)
                    }
                        
                }
            } else{
                HStack{
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    LottieView(animation: .named("wrong"))
                        .playing()
                        .frame(width: lottieFileWidth, height: lottieFileHeight)
                }
                .frame(width: cardWidth, height: cardHeight)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mainColor, lineWidth: 1)
                )
                .popUp()
                .onTapGesture{
                    PopUpGenerator.shared.show(msg: "The date is not confirmed", type: .information)
                }
            }
            
            // MARK: Location
            if isLocationConfirmed{
                HStack{
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    LottieView(animation: .named("wrong"))
                        .playing()
                        .frame(width: lottieFileWidth, height: lottieFileHeight)
                    
                }
                .frame(width: cardWidth, height: cardHeight)
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
                    PopUpGenerator.shared.show(msg: "The location is confirmed", type: .information)
                }
            } else{
                HStack{
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    LottieView(animation: .named("wrong"))
                        .playing()
                        .frame(width: lottieFileWidth, height: lottieFileHeight)
                }
                .frame(width: cardWidth, height: cardHeight)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mainColor, lineWidth: 1)
                )
                .popUp()
                .onTapGesture{
                    PopUpGenerator.shared.show(msg: "The location is not confirmed", type: .information)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    DateLocationRow(
        isDateConfirmed: false,
        isLocationConfirmed: false)
}
