//
//  ConfirmEventSheet.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 05/05/26.
//


import SwiftUI
import MapKit

// MARK: - Helper Struct per appiattire tutte le location e renderle selezionabili sulla mappa
struct MapSelectableItem: Identifiable, Equatable {
    let id = UUID()
    let dateEntry: DateLocationEntry
    let location: LocationPoint
    let displayIndex: Int
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: MapSelectableItem, rhs: MapSelectableItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Il Nuovo Bottom Sheet Interattivo
struct ConfirmEventSheet: View {
    var dateLocations: [DateLocationEntry]
    var onConfirm: (DateLocationEntry, LocationPoint, Date, Date) -> Void
    
    // Stati per la selezione
    @State private var selectedItem: MapSelectableItem?
    @State private var finalStartDate: Date = Date()
    @State private var finalEndDate: Date = Date()
    
    // Generiamo una lista piatta di tutte le location da mostrare sulla mappa
    private var mapItems: [MapSelectableItem] {
        var items: [MapSelectableItem] = []
        var counter = 1
        for entry in dateLocations {
            for loc in entry.locations {
                items.append(MapSelectableItem(
                    dateEntry: entry,
                    location: loc,
                    displayIndex: counter,
                    coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                ))
                counter += 1
            }
        }
        return items
    }
    
    // Calcoliamo l'inquadratura iniziale usando la tua logica
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor.ignoresSafeArea() // Usa il colore di background del tuo progetto
                
                VStack(spacing: 0) {
                    // MARK: - LA MAPPA INTERATTIVA
                    Map(position: $cameraPosition) {
                        ForEach(mapItems) { item in
                            Annotation("", coordinate: item.coordinate) {
                                Button {
                                    // Seleziona il pin con animazione
                                    withAnimation(.spring()) {
                                        selectedItem = item
                                        finalStartDate = item.dateEntry.startDateTime
                                        finalEndDate = item.dateEntry.endDateTime
                                    }
                                } label: {
                                    // Usiamo il tuo pin, ma lo evidenziamo se è selezionato
                                    MapPinView(index: item.displayIndex)
                                        .scaleEffect(selectedItem == item ? 1.4 : 1.0) // Si ingrandisce se tappato
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedItem == item ? 3 : 0)
                                                .scaleEffect(selectedItem == item ? 1.4 : 1.0)
                                        )
                                        .shadow(color: selectedItem == item ? .white.opacity(0.8) : .black.opacity(0.3), radius: selectedItem == item ? 8 : 4)
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                    
                    // MARK: - SELEZIONE DELLA DATA DEFINITIVA
                    ScrollView {
                        if let selected = selectedItem {
                            VStack(alignment: .leading, spacing: 20) {
                                
                                Text("📍 Location \(selected.displayIndex) Selected")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Refine Exact Event Time")
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)) // Il tuo colore accent
                                        .padding(.horizontal)
                                    
                                    DatePicker("Start", selection: $finalStartDate)
                                        .colorScheme(.dark)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    
                                    DatePicker("End", selection: $finalEndDate)
                                        .colorScheme(.dark)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.top, 10)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            // Messaggio che invita a tappare sulla mappa
                            VStack(spacing: 12) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Tap a pin on the map to select the final location.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 50)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Confirm Final Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm") {
                        if let selected = selectedItem {
                            // Passiamo il singolo entry, la location esatta, e le nuove date definitive!
                            onConfirm(selected.dateEntry, selected.location, finalStartDate, finalEndDate)
                        }
                    }
                    .disabled(selectedItem == nil) // Disattivato finché non tappe su un pin
                    .fontWeight(.bold)
                    .foregroundColor(selectedItem == nil ? .gray : Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                }
            }
            .onAppear {
                setupInitialCameraPosition()
            }
        }
    }
    
    // Funzione che calcola lo zoom della mappa in base a tutti i pin presenti
    private func setupInitialCameraPosition() {
        let coords = mapItems.map { $0.coordinate }
        guard !coords.isEmpty else { return }
        if coords.count == 1 {
            cameraPosition = .region(MKCoordinateRegion(
                center: coords[0],
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
            return
        }
        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (lats.max()! - lats.min()!) * 1.8 + 0.01,
            longitudeDelta: (lons.max()! - lons.min()!) * 1.8 + 0.01
        )
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
}
