//
//  VisibilitySelector.swift
//  sbud
//
//  Created by ahmed on 15/04/2026.
//

import SwiftUI

struct VisibilitySelector: View {
    @Binding var isPublic: Bool
    var body: some View {
        VStack{
            HStack{
                Text("Visibility")
                    .foregroundColor(Color.mainColor)
                    .font(.title2)
                    .padding()
                Spacer()
            }
            
            HStack{
                VStack(spacing: 10){
                    HStack{
                        Text("Public")
                            .font(.system(size: 17))
                            .foregroundColor(isPublic ? .black : .gray)
                            .animation(.easeInOut(duration: 0.25), value: isPublic)
                            .padding(.horizontal)
                        Spacer()
                    }
                    HStack{
                        Text("Visible to everyone ")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
                .padding(.vertical)
                Image(systemName: "eye.fill")
                    .font(.system(size: 20))
                    .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity)
            .background(isPublic ? Color.mainColor : Color.backgroundColor)
            .animation(.easeInOut(duration: 0.25), value: isPublic)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .padding(.horizontal)
            .padding(.top)
            .onTapGesture {
                isPublic = true
            }
            
            
            HStack{
                VStack(spacing: 10){
                    HStack{
                        Text("Private")
                            .font(.system(size: 17))
                            .foregroundColor(!isPublic ? .black : .gray)
                            .animation(.easeInOut(duration: 0.25), value: isPublic)
                            .padding(.horizontal)
                        Spacer()
                    }
                    HStack{
                        Text("Visible to friends ")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
                .padding(.vertical)
                Image(systemName: "lock")
                    .font(.system(size: 20))
                    .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity)
            .background(!isPublic ? Color.mainColor : Color.backgroundColor)
            .animation(.easeInOut(duration: 0.25), value: isPublic)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .padding()
            .onTapGesture {
                isPublic = false
            }
        }
        .background(Color.backgroundColor.colorMultiply(.white.opacity(0.5)))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding()
    }
}

#Preview {
    VisibilitySelector(isPublic: .constant(true))
}
