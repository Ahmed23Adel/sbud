//
//  EventContactsListView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 27/04/26.
//

import SwiftUI
import Kingfisher

struct EventContactsListView: View {
    @StateObject var viewModel: EventContactsViewModel
    
    init(eventId: String) {
        _viewModel = StateObject(wrappedValue: EventContactsViewModel(eventId: eventId))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoadingContacts {
                ProgressView()
                    .padding()
            } else if viewModel.contactedUsers.isEmpty {
                Text("No one has contacted you for this event yet.")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.contactedUsers) { userProfile in
                        NavigationLink(destination: ChatView(user: userProfile, eventId: viewModel.eventId)) {
                            HStack {
                                // Immagine Profilo
                                if let imageUrl = userProfile.profileImageUrl, let url = URL(string: imageUrl) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("\(userProfile.name) \(userProfile.surName)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.1))
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

#Preview {
    EventContactsListView(eventId: "test_event_id_123")
}
