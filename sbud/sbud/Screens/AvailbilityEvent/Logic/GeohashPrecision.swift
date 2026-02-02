//
//  GeohasPrecision.swift
//  sbud
//
//  Created by ahmed on 24/12/2025.
//

import Foundation

enum GeohashPrecision: Int {
    case continent = 1
    case country  = 2
    case largeCity = 3
    case city = 4
    case neighbourhood = 5
    case district = 6
    case individuals = 8
}
