//
//  TeamCapacity.swift
//  sbud
//
//  Created by ahmed on 15/04/2026.
//

import SwiftUI

struct TeamCapacitySelector: View {
    @Binding var capacity: Int
    @FocusState var isKeyboardFocused: Bool
    var capacityString: Binding<String>{
        Binding<String>(
            get: {String(capacity)},
            set: {
                capacity = Int($0) ?? capacity
            }
        )
    }
    var body: some View {
        VStack{
            HStack{
                VStack(spacing: 12){
                    Text("Team Capacity")
                        .foregroundColor(Color.mainColor)
                        .font(.title2)
                        .padding(.top)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Maximum participants")
                        .foregroundColor(.gray)
                        .font(.title3)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    
                }
                Spacer()
            }
            
            HStack{
                Spacer()
                Button("-"){
                    capacity -= 1
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .font(.system(size: 55))
                
                TextField("", text: capacityString)
                    .foregroundColor(.white)
                    .font(.system(size: 50))
                    .frame(width: 100)
                    .keyboardType(.numberPad)
                    .focused($isKeyboardFocused)
                Button("+"){
                    capacity += 1
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .font(.system(size: 50))
                
                Spacer()
            }
            .frame(width: 250)
            .background(Color.backgroundColor.colorMultiply(.black.opacity(0.3)))
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .padding()
            
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding()
        .toolbar{
            ToolbarItemGroup(placement: .keyboard){
                Spacer()
                Button("✓"){
                    isKeyboardFocused = false
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

#Preview {
    TeamCapacitySelector(capacity: .constant(12))
}
