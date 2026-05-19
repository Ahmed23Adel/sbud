//
//  StepFourView.swift
//  sbud
//
//  Created by Erdal on 15.04.2026.
//

import SwiftUI
import MapKit
 
struct StepFourView: View {
 
    @EnvironmentObject private var vm: ProfileSetupVM
    @EnvironmentObject private var appCoordinator: MainCoordinator
 
    @State private var cameraPosition: MapCameraPosition = .automatic
 
    private let mapHeight: CGFloat = UIScreen.main.bounds.height * 0.48
 
    var body: some View {
        VStack(spacing: 0) {
            mapSection
            infoSection
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            Task {
                await vm.location.load()
                updateCamera()
            }
        }
        .onChange(of: vm.location.latitude) { _ in updateCamera() }
    }
 
    // MARK: - Map
 
    private var mapSection: some View {
        ZStack(alignment: .bottomLeading) {
            Map(position: $cameraPosition) {
                if vm.location.isAcquired {
                    Annotation("", coordinate: CLLocationCoordinate2D(
                        latitude:  vm.location.latitude,
                        longitude: vm.location.longitude
                    )) {
                        LocationPulseView()
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: [], showsTraffic: false))
            .environment(\.colorScheme, .dark)
            .grayscale(0.6)
            .brightness(-0.1)
            .overlay {
                RadialGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    center: .center,
                    startRadius: 80,
                    endRadius: 420
                )
                .allowsHitTesting(false)
            }
 
            Text(coordinateLabel)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color("turquoise"))
                .padding(.leading, 20)
                .padding(.bottom, 16)
        }
        .frame(height: mapHeight)
        .padding(.top, -UIApplication.safeAreaTop)
        .clipped()
    }
 
    // MARK: - Info + buttons
 
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("FINAL STEP — GEO VERIFICATION")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color("turquoise"))
                .padding(.bottom, 12)
 
            Text("LOCATING\n       COORDINATES")
                .font(.system(size: 34, weight: .black))
                .foregroundColor(.white)
                .lineSpacing(2)
                .padding(.bottom, 16)
 
            Text("We use your location to find people around you. Enabling access allows the app to bridge the gap between technical data and real world performance.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.5))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
 
            Spacer(minLength: 24)
 
            VStack(spacing: 8) {
                allowButton
                notNowButton
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, UIApplication.safeAreaBottom + 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
    }
 
    // MARK: - Action buttons
 
    private var allowButton: some View {
        Button {
            Task {
                let success = await vm.save()
                if success { appCoordinator.goToHome() }
            }
        } label: {
            ZStack {
                if vm.isSaving || vm.location.isLoading {
                    ProgressView().tint(Color(red: 0.15, green: 0.25, blue: 0.0))
                } else {
                    Text("ALLOW ACCESS")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(Color("palelime"))
            .clipShape(Rectangle())
        }
    }
 
    private var notNowButton: some View {
        // "Not now" goes back one step via the environment coordinator.
        // We use a local env object just for goBack; the step coordinator
        // is the source of truth for navigation.
        Button {
            // Re-use the ProfileSetupCoordinator injected higher up.
            // Because StepFourView is embedded inside ProfileSetupView
            // which injects the coordinator as an environment object,
            // we access it here the same way.
        } label: {
            Text("NOT NOW")
                .font(.system(size: 17, weight: .heavy))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.white.opacity(0.05))
                .clipShape(Rectangle())
        }
    }
 
    // MARK: - Helpers
 
    private var coordinateLabel: String {
        guard vm.location.isAcquired else { return "LOC: ACQUIRING..." }
        let lat = vm.location.latitude
        let lon = vm.location.longitude
        return "LOC: \(String(format: "%.4f", abs(lat)))° \(lat >= 0 ? "N" : "S"), "
             + "\(String(format: "%.4f", abs(lon)))° \(lon >= 0 ? "E" : "W")"
    }
 
    private func updateCamera() {
        guard vm.location.isAcquired else { return }
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude:  vm.location.latitude,
                longitude: vm.location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        ))
    }
}
 
// MARK: - Pulse animation (unchanged, kept here as it is only used by StepFourView)
 
struct LocationPulseView: View {
 
    @State private var pulse1 = false
    @State private var pulse2 = false
 
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("palelime").opacity(0.3), lineWidth: 1)
                .frame(width: 68, height: 68)
                .scaleEffect(pulse1 ? 1.7 : 1.0)
                .opacity(pulse1 ? 0 : 0.9)
                .animation(.easeOut(duration: 2.4).repeatForever(autoreverses: false), value: pulse1)
 
            Circle()
                .stroke(Color("palelime").opacity(0.45), lineWidth: 1.2)
                .frame(width: 42, height: 42)
                .scaleEffect(pulse2 ? 1.6 : 1.0)
                .opacity(pulse2 ? 0 : 1.0)
                .animation(.easeOut(duration: 2.4).delay(0.7).repeatForever(autoreverses: false), value: pulse2)
 
            Circle()
                .fill(Color("palelime").opacity(0.2))
                .frame(width: 22, height: 22)
 
            Circle()
                .strokeBorder(.white, lineWidth: 1.5)
                .background(Circle().fill(Color("palelime")))
                .frame(width: 13, height: 13)
 
            Circle()
                .fill(.white)
                .frame(width: 4, height: 4)
        }
        .onAppear { pulse1 = true; pulse2 = true }
    }
}
 
