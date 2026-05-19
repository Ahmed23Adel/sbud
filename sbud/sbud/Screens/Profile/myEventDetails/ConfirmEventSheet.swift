//
//  ConfirmEventSheet.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 05/05/26.
//


import SwiftUI
import MapKit
import EventKit

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

struct ConfirmEventSheet: View {
    var eventTitle: String 
    var dateLocations: [DateLocationEntry]
    var onConfirm: (DateLocationEntry, LocationPoint, Date, Date) -> Void
    
    @State private var selectedItem: MapSelectableItem?
    @State private var finalStartDate: Date = Date()
    @State private var finalEndDate: Date = Date()
    
    @State private var showCalendarPrompt = false
    
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
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Custom Top Bar
                    HStack {
                        Text("Confirm Final Details")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.mainColor)
                        
                        Spacer()
                        
                        Button {
                            //  show the enetkit pop up instead directly confirming
                            if selectedItem != nil {
                                showCalendarPrompt = true
                            }
                        } label: {
                            Text("Confirm")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedItem == nil
                                        ? Color.mainColor.opacity(0.4)
                                        : Color.mainColor
                                )
                                .clipShape(Capsule())
                        }
                        .disabled(selectedItem == nil)
                        .buttonStyle(.plain)
                        // MARK: Pop-up del Calendario
                        .alert("Add to Caledar", isPresented: $showCalendarPrompt) {
                            Button("Yes, Add") {
                                if let selected = selectedItem {
                                    saveToCalendar(title: eventTitle, start: finalStartDate, end: finalEndDate, coord: selected.coordinate)
                                    onConfirm(selected.dateEntry, selected.location, finalStartDate, finalEndDate)
                                }
                            }
                            Button("No, thank you", role: .cancel) {
                                if let selected = selectedItem {
                                    onConfirm(selected.dateEntry, selected.location, finalStartDate, finalEndDate)
                                }
                            }
                        } message: {
                            Text("Do you want to save this event to your Apple Calendar?")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // MARK: - Map
                    Map(position: $cameraPosition) {
                        ForEach(mapItems) { item in
                            Annotation("", coordinate: item.coordinate) {
                                Button {
                                    withAnimation(.spring()) {
                                        selectedItem = item
                                        finalStartDate = item.dateEntry.startDateTime
                                        finalEndDate = item.dateEntry.endDateTime
                                    }
                                } label: {
                                    MapPinView(index: item.displayIndex)
                                        .scaleEffect(selectedItem == item ? 1.4 : 1.0)
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
                    
                    // MARK: - Selection Detail
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
                                        .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
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
            .navigationBarHidden(true)
            .onAppear {
                setupInitialCameraPosition()
            }
        }
    }
    
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
    
    
    private func saveToCalendar(title: String, start: Date, end: Date, coord: CLLocationCoordinate2D) {
        
        Task {
            let store = EKEventStore()
            
            do {
                var granted = false
                
                
                if #available(iOS 17.0, *) {
                    granted = try await store.requestWriteOnlyAccessToEvents()
                } else {
                    granted = try await store.requestAccess(to: .event)
                }
                
                guard granted else {
                    print("❌ The user has denied permissions for Calendar.")
                    return
                }
                
                // Creazione Evento calendario
                let event = EKEvent(eventStore: store)
                event.title = title
                event.startDate = start
                event.endDate = end
                
                let location = EKStructuredLocation(title: "Location Event")
                location.geoLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                event.structuredLocation = location
                
                // 3. FIX CRUCIALE: Controllo validità Calendario
                if let defaultCalendar = store.defaultCalendarForNewEvents {
                    event.calendar = defaultCalendar
                } else if let fallbackCalendar = store.calendars(for: .event).first(where: { $0.allowsContentModifications }) {
                    
                    //  fallback lo va a pescare "di forza" dall'array dei calendari modificabili.
                    event.calendar = fallbackCalendar
                } else {
                    print("❌ ERROR: No editable calendars found on the device.")
                    return
                }
                
                
                try store.save(event, span: .thisEvent)
                print("✅Event saved successfully")
                
            } catch {
                print("❌ Error saving to EventKit: \(error.localizedDescription)")
            }
        }
    }
}
