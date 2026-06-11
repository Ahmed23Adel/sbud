//
//  ViewHostsList.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

struct EventHost: Identifiable {
    var id: String
    var name: String
    var surName: String
    var profileImageUrl: String?
    var fullName: String { "\(name) \(surName)".trimmingCharacters(in: .whitespaces) }
}

@Observable
class ViewModelHostsList {
    var hosts: [EventHost] = []
    var isLoading = false
    let eventId: String

    init(eventId: String) {
        self.eventId = eventId
        Task { await loadHosts() }
    }

    func loadHosts() async {
        await MainActor.run { isLoading = true }
        do {
            let db = Firestore.firestore()
            let snapshot = try await db
                .collection("Events").document(eventId)
                .collection("hosts")
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()

            var result: [EventHost] = []
            for doc in snapshot.documents {
                let data = doc.data()
                let userId = doc.documentID
                // User bilgisini çek
                let userSnap = try await db.collection("users").document(userId).getDocument()
                let userData = userSnap.data() ?? [:]
                result.append(EventHost(
                    id: userId,
                    name: userData["name"] as? String ?? "",
                    surName: userData["surName"] as? String ?? "",
                    profileImageUrl: userData["profileImageUrl"] as? String
                ))
            }

            await MainActor.run {
                hosts = result
                isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
        }
    }
}

struct ViewHostsList: View {
    @State private var viewModel: ViewModelHostsList
    let onTapHost: (String) -> Void
    let onDismiss: () -> Void

    init(eventId: String, onTapHost: @escaping (String) -> Void, onDismiss: @escaping () -> Void) {
        _viewModel = State(wrappedValue: ViewModelHostsList(eventId: eventId))
        self.onTapHost = onTapHost
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.backgroundColor)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Hosts")
                        .font(.headline).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding()

                if viewModel.isLoading {
                    ProgressView().tint(Color.mainColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.hosts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No hosts yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.hosts) { host in
                                Button {
                                    onTapHost(host.id)
                                } label: {
                                    HStack(spacing: 12) {
                                        KFImage(host.profileImageUrl.flatMap { URL(string: $0) })
                                            .placeholder {
                                                Circle().fill(Color.gray.opacity(0.3))
                                                    .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                                            }
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 48)
                                            .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(host.fullName)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                            Text("Host")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color("palelime"))
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.backgroundColor)
                                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}
