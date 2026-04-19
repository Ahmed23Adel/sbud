//
//  StepFourView.swift
//  sbud
//
//  Created by Erdal on 15.04.2026.
//

import SwiftUI
import MapKit

struct StepFourView: View {
    @EnvironmentObject var vm: ProfileSetupVM
    @EnvironmentObject var coordinator: MainCoordinator
    @State private var cameraPosition: MapCameraPosition = .automatic

    // Ekran yüksekliğinin %48'i — GeometryReader'a gerek yok
    private let mapHeight: CGFloat = UIScreen.main.bounds.height * 0.48

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Harita
            ZStack(alignment: .bottomLeading) {
                Map(position: $cameraPosition) {
                    if vm.profile.location.latitude != 0 {
                        Annotation("", coordinate: CLLocationCoordinate2D(
                            latitude: vm.profile.location.latitude,
                            longitude: vm.profile.location.longitude
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

                // LOC yazısı
                Text(locText)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color("turquoise"))
                    .padding(.leading, 20)
                    .padding(.bottom, 16)
            }
            .frame(height: mapHeight)
            // Haritayı status bar'a kadar taşı
            .padding(.top, -UIApplication.safeAreaTop)
            // Ama ZStack'in geri kalanı etkilenmesin diye aynı miktarı geri ekle
            .clipped()

            // MARK: - İçerik
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

                allowButton
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, UIApplication.safeAreaBottom + 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.05, green: 0.05, blue: 0.05))
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            Task {
                await vm.loadCurrentLocation()
                updateMap()
            }
        }
        .onChange(of: vm.profile.location.latitude) { _ in
            updateMap()
        }
    }

    private var locText: String {
        let lat = vm.profile.location.latitude
        let lon = vm.profile.location.longitude
        guard lat != 0 else { return "LOC: ACQUIRING..." }
        let latDir = lat >= 0 ? "N" : "S"
        let lonDir = lon >= 0 ? "E" : "W"
        return "LOC: \(String(format: "%.4f", abs(lat)))° \(latDir), \(String(format: "%.4f", abs(lon)))° \(lonDir)"
    }
}

// MARK: - Subviews
private extension StepFourView {

    var allowButton: some View {
        Button {
            Task {
                let success = await vm.save()
                if success { coordinator.goToHome() }
            }
        } label: {
            ZStack {
                if vm.isSaving || vm.isLoading {
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
        .padding(.bottom, 8)
    }

    func updateMap() {
        guard vm.profile.location.latitude != 0 else { return }
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: vm.profile.location.latitude,
                longitude: vm.profile.location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        ))
    }
}

// MARK: - Pulse Animasyonu
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

// MARK: - UIApplication Safe Area Helper
private extension UIApplication {
    static var safeAreaTop: CGFloat {
        shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }

    static var safeAreaBottom: CGFloat {
        shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}


