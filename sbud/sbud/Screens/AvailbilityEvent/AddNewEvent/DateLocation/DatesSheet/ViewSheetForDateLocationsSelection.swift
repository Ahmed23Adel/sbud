//
//  SheetForDatesSelection.swift
//  sbud
//
//  Created by ahmed on 07/03/2026.
//

import SwiftUI
import _MapKit_SwiftUI
import FirebaseFirestore

struct ViewSheetForDateLocationsSelection: View {
    @State var startDate: Date? = nil
    @State var endDate: Date? = nil
    @State var pickedCoordinates: [CLLocationCoordinate2D] = []
    var returnables: MultipleDateLocationsHolder
    @Environment(\.dismiss) var dismiss

    var isFormValid: Bool {
        guard let start = startDate, let end = endDate else { return false }
        return end > start && !pickedCoordinates.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Start Date
            if let start = startDate {
                DatePicker("Start date time",
                           selection: Binding(
                               get: { start },
                               set: { newStart in
                                   startDate = newStart
                                   // Reset end date if it's no longer valid
                                   if let end = endDate, end <= newStart {
                                       endDate = nil
                                   }
                               }
                           ),
                           displayedComponents: [.date, .hourAndMinute]
                )
                .font(.headline)
                .foregroundStyle(Color.mainColor)
                .datePickerStyle(.compact)
                .tint(.mainColor)
                .padding()
                .transition(.opacity)
            } else {
                Button {
                    withAnimation {
                        startDate = Date()
                    }
                } label: {
                    Label("Set start date", systemImage: "calendar.badge.plus")
                        .font(.headline)
                        .foregroundStyle(Color.mainColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .transition(.opacity)
            }

            // MARK: End Date (only shown after start date is set)
            if let start = startDate {
                Divider().padding(.horizontal)

                if let end = endDate {
                    DatePicker("End date time",
                               selection: Binding(
                                   get: { end },
                                   set: { endDate = $0 }
                               ),
                               in: start.addingTimeInterval(60)...,
                               displayedComponents: [.date, .hourAndMinute]
                    )
                    .font(.headline)
                    .foregroundStyle(Color.mainColor)
                    .tint(.mainColor)
                    .padding()
                    .transition(.opacity)
                } else {
                    Button {
                        withAnimation {
                            endDate = start.addingTimeInterval(3600)
                        }
                    } label: {
                        Label("Set end date", systemImage: "calendar.badge.plus")
                            .font(.headline)
                            .foregroundStyle(Color.mainColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .transition(.opacity)
                }
            }

            Divider().padding(.horizontal)

            MapTabView(pickedCoordinates: $pickedCoordinates)
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 21))

            Button("Submit") {
                guard
                    let start = startDate,
                    let end = endDate,
                    end > start
                else { return }

                let oneReturnables = DateLocations(
                    startDateTime: start,
                    endDateTime: end,
                    locations: pickedCoordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
                )
                returnables.append(oneReturnables)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.mainColor)
            .frame(maxWidth: .infinity)
            .padding()
            .disabled(!isFormValid)
        }
        .frame(maxHeight: .infinity)
        .background(Color.backgroundColor)
        .animation(.easeInOut, value: startDate == nil)
        .animation(.easeInOut, value: endDate == nil)
    }
}

#Preview {
//    ViewSheetForDateLocationsSelection()
}
