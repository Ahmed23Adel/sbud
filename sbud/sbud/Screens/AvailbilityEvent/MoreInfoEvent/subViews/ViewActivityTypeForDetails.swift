//
//  ViewActivityTypeForDetails.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct ViewActivityTypeForDetails: View {
    var activityType: ActivityType
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .frame(height: 100)
                .foregroundColor(Color.mainColor)
                .padding(.horizontal, 15)
            
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .frame(height: 100)
                .foregroundColor(Color.backgroundColor)
                .padding(.horizontal, 15)
                .padding(.leading, 10)
            
            VStack{
                HStack{
                    Text("ACTIVITY TYPE")
                        .font(.system(size: 10))
                        .foregroundColor(Color.mainColor)
                        .padding(.horizontal, 35)
                        .padding(.top, 10)
                        .italic()
                    Spacer()
                }
                HStack{
                    
                    Text(activityType.rawValue)
                        .font(.title)
                        .foregroundColor(Color.mainColor)
                        .padding(.horizontal, 35)
                        .padding(.top, 10)
                        .italic()
                    Spacer()
                }
                
            }
        }
    }
}

#Preview {
    ViewActivityTypeForDetails(activityType: .running)
}
