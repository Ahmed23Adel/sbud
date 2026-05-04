//
//  EventContactsListView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//
import SwiftUI
import Kingfisher

struct EventContactsListView: View {
    @StateObject var viewModel: EventContactsViewModel
    let eventTitle: String // 1. AGGIUNTO IL TITOLO DELL'EVENTO
    
    // 2. AGGIUNTO IL TITOLO ALL'INIT (con un valore di default per non rompere il codice esistente)
    init(eventId: String, eventTitle: String = "Event Chat") {
        self.eventTitle = eventTitle
        _viewModel = StateObject(wrappedValue: EventContactsViewModel(eventId: eventId))
    }
    
    var body: some View {
        ZStack {
            // COLORE APP: Sfondo scuro per tutta la vista
            Color.darkBackground.ignoresSafeArea()
            
            VStack {
                if viewModel.isLoadingContacts {
                    ProgressView()
                        .tint(Color.mainColor) // COLORE APP
                        .padding()
                } else if viewModel.contactedUsers.isEmpty {
                    Text("No one has contacted you for this event yet.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.contactedUsers) { userProfile in
                            
                            // 3. FIX APPLICATO: Ora passiamo l'eventTitle alla ChatView
                            NavigationLink(destination: ChatView(user: userProfile, eventId: viewModel.eventId, eventTitle: self.eventTitle)) {
                                HStack {
                                    // Immagine Profilo
                                    if let imageUrl = userProfile.profileImageUrl, let url = URL(string: imageUrl) {
                                        KFImage(url)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.mainColor, lineWidth: 1)) // COLORE APP: Bordo lime
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.backgroundColor) // COLORE APP
                                    }
                                    
                                    Text("\(userProfile.name) \(userProfile.surName)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white) // Testo bianco per contrasto
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.mainColor) // COLORE APP: Freccia lime
                                }
                                .padding()
                                .background(Color.backgroundColor) // COLORE APP: Cella grigia
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
    }
}
