//
//  ProposalVsDeterminedPhase.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct ProposalVsDeterminedPhase: View {
    var isDateConfirmed: Bool
    var isLocationConfirmed: Bool
    var body: some View {
        HStack{
            if isDateConfirmed && isLocationConfirmed{
                Text("Determined")
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color(red: 0, green: 227/255,blue: 253/255))
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                
                    
            } else{
                Text("Proposal phase")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(Color.mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    
                
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        
    }
}

#Preview {
    ProposalVsDeterminedPhase(isDateConfirmed: true, isLocationConfirmed: true)
}
