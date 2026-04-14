// DateLocationRow.swift
// sbud
//
// Created by ahmed on 04/02/2026.
//
import SwiftUI
import Lottie

struct DateLocationRow: View {
    var cardWidth: CGFloat = UIConstants.smallCardWidth
    var cardHeight: CGFloat = UIConstants.smallCardHeight
    var isDateConfirmed: Bool
    var isLocationConfirmed: Bool
    
    var body: some View {
        HStack{
            // MARK: Date
            Spacer()
            if isDateConfirmed{
                HStack{
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                        .popUp()
                }
                .frame(width: cardWidth, height: cardHeight)
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
            } else{
                HStack{
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color.red)
                        .popUp()
                }
                .frame(width: cardWidth, height: cardHeight)
                .background(
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                        .fill(Color.backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
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
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                        .popUp()
                }
                .frame(width: cardWidth, height: cardHeight)
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
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color.red)
                        .popUp()
                }
                .frame(width: cardWidth, height: cardHeight)
                .background(
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                        .fill(Color.backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
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
