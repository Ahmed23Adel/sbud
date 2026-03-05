//
//  NewMessageView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import SwiftUI

struct NewMessageView: View {
    @State var searchText = ""
    @Binding var startChat: Bool
    @Binding var user: User?
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel = SearchViewModel(config: .newMessage)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                TextField("To: ", text: $searchText)
                    .frame(height: 44)
                    .padding(.leading)
                    .background(Color(.systemGroupedBackground))

                LazyVStack(alignment: .leading) {
                    ForEach(searchText.isEmpty ? viewModel.users : viewModel.filteredUsers(searchText)) { user in
                        HStack { Spacer() }
                        
                        UserCell(user: user)
                            .onTapGesture {
                                self.user = user
                                dismiss()           
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    startChat = true
                                }
                            }
                    }
                }
                .padding(.leading)
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

