//
//  CreatorInboxCard.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


import SwiftUI

struct CreatorInboxCard: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Event Inbox")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Check messages from interested people")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.mainColor) 
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "tray.full.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .semibold))
                }
            }
            .padding()
            .background(Color.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12)) 
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}
