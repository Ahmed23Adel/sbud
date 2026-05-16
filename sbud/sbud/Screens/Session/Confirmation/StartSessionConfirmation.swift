//
//  StartSessionConfirmation.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct StartSessionConfirmation: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: MainCoordinator
    let eventDetails: EventFullDetails
    
    
    var body: some View {
        VStack{
            Text("Start session now?")
                .font(.title)
                .foregroundColor(Color.mainColor)
                .bold()
                .padding()
                
            
            Button("Yes"){
                coordinator.navigateTo(.creatorSession(eventDetails: eventDetails, isSessionCreated: false))
            }
            .buttonStyle(PrimaryButton())
            
            Button("No"){
                dismiss()
            }
            .buttonStyle(DestructiveButton())
        
            
            
            
        }
        .frame(maxHeight: .infinity)
        .background(Color.darkBackground)
    }
}
//
//#Preview {
//    StartSessionConfirmation(eventId: "")
//}
