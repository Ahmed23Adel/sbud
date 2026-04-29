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
    
    // MARK: - Activity type UI
    private var activityType: ActivityType {
        ActivityType(rawValue: event.activityType) ?? .running
    }
    
    private var activityIcon: String {
        switch activityType {
        case .running:  return "figure.run"
        case .cycling:  return "figure.outdoor.cycle"
        case .gym:      return "dumbbell.fill"
        case .skiing:   return "figure.skiing.downhill"
        case .swimming: return "figure.pool.swim"
        case .hiking:   return "figure.hiking"
        case .yoga:     return "figure.yoga"
        case .tennis:   return "figure.tennis"
        }
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
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
                        .frame(width: 140, height: 180)
                        .clipped()
                    
                    HStack(spacing: 4) {
                        Image(systemName: activityIcon)
                            .font(.system(size: 9, weight: .bold))
                        
                        Text(event.activityType.uppercased())
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("palelime"))
                    .clipShape(Capsule())
                    .padding(.top, 15)
                    .padding(.leading, 15)
                }
                .frame(width: 140, height: 180, alignment: .topLeading)
                
                // MARK: RIGHT
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Text(event.fullDatailedEvent?.title.uppercased() ?? "zero")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                        
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
                            .frame(width: 18, height: 18)
                            
                            Text(vm.displayName(fallback: event.creatorName).uppercased())
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    Divider().background(Color.white.opacity(0.15))
                    
                    // MARK: Metrikler
                    metricsRow
                }
                .padding(16)
                .background(Color.black)
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
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .task {
            async let profile: () = vm.fetchUser(userId: event.creatorUserId ?? "")
            async let details: () = vm.fetchEventDetails(eventId: event.eventId)
            _ = await (profile, details)
        }
    }
    
    
    // MARK: - Metrics Row
    @ViewBuilder
    private var metricsRow: some View {
        if vm.metrics.isEmpty {
            // Yükleniyor
            HStack(spacing: 16) {
                metricItem(label: "—", value: "—")
                metricItem(label: "—", value: "—")
            }
        } else {
            HStack(spacing: 16) {
                ForEach(vm.metrics, id: \.label) { m in
                    metricItem(label: m.label, value: m.value)
                }
                Spacer()
            }
        }
    }
    
    private func metricItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color("turquoise"))
                .lineLimit(1)
        }
    }
}
