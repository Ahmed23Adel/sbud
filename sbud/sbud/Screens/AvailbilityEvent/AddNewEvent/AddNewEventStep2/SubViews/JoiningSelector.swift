//
//  JoiningSelector.swift
//  sbud
//
//  Created by ahmed on 15/04/2026.
//

import SwiftUI

struct JoiningSelector: View {
    @Binding var joiningCondition: JoinCondition
    var body: some View {
        VStack{
            HStack{
                Text("Joining Protocol")
                    .foregroundColor(Color.mainColor)
                    .font(.title2)
                    .padding()
                Spacer()
            }
            
            HStack{
                VStack(spacing: 10){
                    HStack{
                        Text("Auto Join")
                            .font(.system(size: 17))
                            .foregroundColor(joiningCondition == .autoJoin ? .black : .gray)
                            .animation(.easeInOut(duration: 0.25), value: joiningCondition)
                            .padding(.horizontal)
                        Spacer()
                    }
                    HStack{
                        Text("Instant entry for all buds")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
                .padding(.vertical)
                Image(systemName: "door.left.hand.open")
                    .font(.system(size: 20))
                    .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity)
            .background(joiningCondition == .autoJoin ? Color.mainColor : Color.backgroundColor)
            .animation(.easeInOut(duration: 0.25), value: joiningCondition)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .padding(.horizontal)
            .padding(.top)
            .onTapGesture {
                joiningCondition = .autoJoin
            }
            
            
            HStack{
                VStack(spacing: 10){
                    HStack{
                        Text("Request Only")
                            .font(.system(size: 17))
                            .foregroundColor(joiningCondition == .requestFromHost ? .black : .gray)
                            .animation(.easeInOut(duration: 0.25), value: joiningCondition)
                            .padding(.horizontal)
                        Spacer()
                    }
                    HStack{
                        Text("Manual approval by any hosts")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
                .padding(.vertical)
                Image(systemName: "door.left.hand.closed")
                    .font(.system(size: 20))
                    .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity)
            .background(joiningCondition == .requestFromHost ? Color.mainColor : Color.backgroundColor)
            .animation(.easeInOut(duration: 0.25), value: joiningCondition)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .padding()
            .onTapGesture {
                joiningCondition = .requestFromHost
            }
        }
        .background(Color.backgroundColor.colorMultiply(.white.opacity(0.5)))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding()
    }
}
#Preview {
    JoiningSelector(joiningCondition: .constant(.autoJoin))
}
