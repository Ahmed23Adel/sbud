//
//  ConfirmEventSheet.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 05/05/26.
//


import SwiftUI

import SwiftUI

struct ConfirmEventSheet: View {
    var dateLocations: [DateLocationEntry]
    
    var onConfirm: (DateLocationEntry, LocationPoint, Date, Date) -> Void
    
    @State private var selectedDateEntry: DateLocationEntry?
    @State private var selectedLocation: LocationPoint?
    
    // Nuovi stati per la scelta della data esatta
    @State private var finalStartDate: Date = Date()
    @State private var finalEndDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea() // Sfondo scuro
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Select a location option and confirm the final date and time.")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        ForEach(dateLocations) { dateEntry in
                            VStack(alignment: .leading) {
                                
                                Text("\(dateEntry.startDateTime.formatted(date: .abbreviated, time: .shortened)) - \(dateEntry.endDateTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                
                                ForEach(Array(dateEntry.locations.enumerated()), id: \.element.geohash) { index, location in
                                    Button {
                                        selectedDateEntry = dateEntry
                                        selectedLocation = location
                                        // Quando clicchi, inizializza i DatePicker con le date del range
                                        finalStartDate = dateEntry.startDateTime
                                        finalEndDate = dateEntry.endDateTime
                                    } label: {
                                        HStack {
                                            
                                            Circle()
                                                .fill(Color.teal)
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Text("\(index + 1)")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Lat: \(String(format: "%.4f", location.latitude))")
                                                Text("Lon: \(String(format: "%.4f", location.longitude))")
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .padding(.leading, 8)
                                            
                                            Spacer()
                                            
                                            if selectedDateEntry?.id == dateEntry.id && selectedLocation?.geohash == location.geohash {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.title2)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                                    .font(.title2)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                        }
                        
                        
                        if selectedLocation != nil {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Select Exact Event Time")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                
                                DatePicker("Start", selection: $finalStartDate)
                                    .colorScheme(.dark) // Forza lo stile scuro
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
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Confirm Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm") {
                        if let sDate = selectedDateEntry, let sLoc = selectedLocation {
                            
                            onConfirm(sDate, sLoc, finalStartDate, finalEndDate)
                        }
                    }
                    .disabled(selectedDateEntry == nil || selectedLocation == nil)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
