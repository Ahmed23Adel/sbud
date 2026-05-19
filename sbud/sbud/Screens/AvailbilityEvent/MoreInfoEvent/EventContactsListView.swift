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
    let eventTitle: String
    
    
    init(eventId: String, eventTitle: String = "Event Chat") {
        self.eventTitle = eventTitle
        _viewModel = StateObject(wrappedValue: EventContactsViewModel(eventId: eventId))
    }
    
    var body: some View {
        ZStack {
            
            Color.darkBackground.ignoresSafeArea()
            
            VStack {
                if viewModel.isLoadingContacts {
                    ProgressView()
                        .tint(Color.mainColor)
                        .padding()
                } else if viewModel.contactedUsers.isEmpty {
                    Text("No one has contacted you for this event yet.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.contactedUsers) { userProfile in
                            
                            
                            NavigationLink(destination: ChatView(user: userProfile, eventId: viewModel.eventId, eventTitle: self.eventTitle)) {
                                HStack {
                                    
                                    if let imageUrl = userProfile.profileImageUrl, let url = URL(string: imageUrl) {
                                        KFImage(url)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.mainColor, lineWidth: 1)) 
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.backgroundColor)
                                    }
                                    
                                    Text("\(userProfile.name) \(userProfile.surName)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.mainColor)
                                }
                                .padding()
                                .background(Color.backgroundColor)
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
