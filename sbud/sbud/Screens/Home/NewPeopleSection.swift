//
//  NewPeopleSection.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import SwiftUI
import Kingfisher

struct NewPeopleSection: View {
    let people: [MeetPersonItem]
    let isLoading: Bool
    let onTapProfile: (String) -> Void

    private let lime = Color("palelime")

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                PageSectionTitle(title: "NEW PEOPLE")
                Spacer()
            }

            if isLoading {
                loadingPlaceholder
            } else if people.isEmpty {
                Text("People from shared events will appear here.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(people) { person in
                            Button {
                                onTapProfile(person.userId)
                            } label: {
                                VStack(spacing: 8) {
                                    KFImage(person.profileImageUrl.flatMap { URL(string: $0) })
                                        .placeholder {
                                            Circle().fill(Color.gray.opacity(0.3))
                                                .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                                        }
                                        .resizable().scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(lime.opacity(0.4), lineWidth: 1.5))
                                    Text(person.fullName)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(person.preferredActivity.uppercased())
                                        .font(.system(size: 9, weight: .semibold))
                                        .kerning(0.5)
                                        .foregroundColor(lime)
                                }
                                .frame(width: 72)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding(.horizontal, 16)
    }

    private var loadingPlaceholder: some View {
        HStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(spacing: 8) {
                    Circle().fill(Color(white: 0.1)).frame(width: 64, height: 64)
                    RoundedRectangle(cornerRadius: 4).fill(Color(white: 0.1)).frame(width: 50, height: 10)
                }
            }
        }
    }
}
