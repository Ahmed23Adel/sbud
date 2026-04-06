//
//  LocationPopup.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI
import MapKit

struct LocationPopup: View {
    @EnvironmentObject var vm: ProfileSetupVM
    @EnvironmentObject var coordinator: MainCoordinator
    
    @Binding var showLocationPopup: Bool
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                closeButton
                
                VStack(spacing: 0) {
                    titleSection
                    mapSection
                    allowButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 48)
                .padding(.bottom, 20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            .padding(.horizontal, 14)
            //.padding(.bottom, 0)
        }
    }
}

private extension LocationPopup {
    var closeButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                showLocationPopup = false
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
    
    private func updateMapToCurrentLocation() {
        guard vm.profile.location.latitude != 0,
              vm.profile.location.longitude != 0 else { return }
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: vm.profile.location.latitude,
                    longitude: vm.profile.location.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
    
    var titleSection: some View {
        VStack(spacing: 12) {
            Text("Allow To Use Your Location")
                .font(.system(size: 25, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("We use your location to find people around you.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
    }
    
    var mapSection: some View {
        Map(position: $cameraPosition) {
            if vm.profile.location.latitude != 0 && vm.profile.location.longitude != 0 {
                Annotation(
                    "",
                    coordinate: CLLocationCoordinate2D(
                        latitude: vm.profile.location.latitude,
                        longitude: vm.profile.location.longitude
                    )
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.25))
                            .frame(width: 26, height: 26)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
        .mapStyle(.standard)
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.top, 24)
        .onAppear {
            Task {
                await vm.loadCurrentLocation()
                updateMapToCurrentLocation()
            }
        }
    }
    
    var allowButton: some View {
        Button {
            Task {
                let success = await vm.save()
                if success {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showLocationPopup = false
                    }
                    coordinator.goToHome()
                }
            }
        } label: {
            ZStack {
                if vm.isSaving || vm.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Allow")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(Color.black)
            .clipShape(Capsule())
        }
        .padding(.top, 32)
    }
}
