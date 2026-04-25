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
    @State var startDate = Date()
    @State var endDate = Date()
    @State var isLocationInputted = false
    @State var pickedCoordinates: [CLLocationCoordinate2D] = []
    var returnables: MultipleDateLocationsHolder
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            DatePicker("Start date time",
                       selection: $startDate,
                       displayedComponents: [.date, .hourAndMinute]
            )
            .font(.headline)
            .foregroundStyle(Color.mainColor)
            .datePickerStyle(.compact)
            .tint(.mainColor)
            .padding()
            
            DatePicker("End date time",
                       selection: $endDate,
                       displayedComponents: [.date, .hourAndMinute]
            )
            .font(.headline)
            .foregroundStyle(Color.mainColor)
            .tint(.mainColor)
            .padding()
            
            MapTabView(pickedCoordinates: $pickedCoordinates)
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 21))
            Button("Submit"){
                let oneReturnables = DateLocations(
                    startDateTime: startDate,
                    endDateTime: endDate,
                    locations: pickedCoordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
                )
                returnables.append(oneReturnables)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.mainColor)
            .frame(maxWidth: .infinity)
            .disabled(pickedCoordinates.count == 0)
        }
        .frame(maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}

#Preview {
//    ViewSheetForDateLocationsSelection()
}
