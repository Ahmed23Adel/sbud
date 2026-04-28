//
//  UserCardView.swift
//  sbud
//
//  Created by Erdal on 7.04.2026.
//

import SwiftUI
import Kingfisher
internal import FirebaseFirestoreInternal

struct UserCardView: View {
    let event: AvailabilityEvent

    @StateObject private var vm = UserCardVM()
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    @EnvironmentObject private var mainCoordinator: MainCoordinator

    private var activityColor: Color {
        switch event.activityType.lowercased() {
        case "running": return Color("palelime")
        case "cycling": return Color("turquoise")
        case "gym":     return Color("lightblack")
        default:        return Color.mainColor
        }
    }

    private var activityIcon: String {
        switch event.activityType.lowercased() {
        case "running": return "figure.run"
        case "cycling": return "figure.outdoor.cycle"
        case "gym":     return "dumbbell.fill"
        default:        return "star.fill"
        }
    }

    private var activityTextColor: Color {
        switch event.activityType.lowercased() {
        case "gym": return .white
        default:    return .black
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 0) {
                // MARK: LEFT
                ZStack(alignment: .topLeading) {
                    KFImage(URL(string: event.eventImage))
                        .placeholder {
                            LinearGradient(
                                colors: [Color.black.opacity(0.8), Color.gray.opacity(0.2)],
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            )
                            .background(Color.black)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140)
                        .clipped()

                    HStack(spacing: 4) {
                        Image(systemName: activityIcon)
                            .font(.system(size: 9, weight: .bold))
                        Text(event.activityType.uppercased())
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(activityTextColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(activityColor)
                    .clipShape(Capsule())
                    .padding(15)
                }
                .frame(width: 140)

                // MARK: RIGHT
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(event.creatorName.uppercased())
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()

                        Button {
                            coordinator.dismissPreview()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }

                    Button {
                        coordinator.dismissPreview()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            mainCoordinator.goToProfile(userId: event.creatorUserId ?? "")
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Group {
                                if let urlStr = vm.userProfile?.profileImageUrl,
                                   let url = URL(string: urlStr) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 20, height: 20)

                            Text(vm.displayName(fallback: event.creatorName).uppercased())
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, 2)

                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("TARGET")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.gray)
                            Text(vm.targetDistance ?? "—")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.mainColor)
                        }

                        VStack(alignment: .leading) {
                            Text("PACE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.gray)
                            Text(vm.pace ?? "—")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.0, green: 0.89, blue: 0.99))
                        }
                    }
                    .padding(.bottom, 5)
                }
                .padding(20)
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: 180)

            Button {
                let eventId = event.eventId
                withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                    coordinator.dismissPreview()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                    coordinator.push(.moreInfoEvent(eventId))
                }
            } label: {
                Text("DETAILS")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.mainColor)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .task {
            await vm.fetchUser(userId: event.creatorUserId ?? "")
        }
    }
}
