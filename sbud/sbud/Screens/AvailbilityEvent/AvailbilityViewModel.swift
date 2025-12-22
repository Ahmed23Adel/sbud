//
//  AvailbilityViewModel.swift
//  sbud
//
//  Created by ahmed on 22/12/2025.
//

import Foundation
import Combine
import _MapKit_SwiftUI

class AvailbilityViewModel: ObservableObject{
    @Published var locationManager: LocationManager
    @Published var cameraPosition: MapCameraPosition = .automatic
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager){
        print("1")
        self.locationManager = locationManager
        print("2")
        requestPermissionForLocation()
        setupLocationObserver()
    }
    
    private func requestPermissionForLocation(){
        locationManager.requestPermission()
        print("requestPermissionForLocation")
    }
    
    
       private func setupLocationObserver() {
           print("setupLocationObserver")
           locationManager.$userLocation
               .compactMap { $0 }
               .first()
               .sink { [weak self] coordinate in
                   self?.cameraPosition = .region(
                       MKCoordinateRegion(
                           center: coordinate,
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                       )
                   )
               }
               .store(in: &cancellables)
       }
   }


