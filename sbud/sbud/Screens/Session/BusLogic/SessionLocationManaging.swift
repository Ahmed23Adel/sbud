//
//  SessionLocationManaging.swift
//  sbud
//

import CoreLocation
import Combine

protocol SessionLocationManaging: AnyObject {
    var lastLocationPublisher: AnyPublisher<CLLocation?, Never> { get }
    func startUpdating()
    func stopUpdating()
    func applyConfiguration(_ configure: (CLLocationManager) -> Void)
}

extension LocationManager: SessionLocationManaging {
    var lastLocationPublisher: AnyPublisher<CLLocation?, Never> {
        $lastLocation.eraseToAnyPublisher()
    }
}
