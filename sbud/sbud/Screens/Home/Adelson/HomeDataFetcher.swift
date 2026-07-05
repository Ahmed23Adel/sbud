//
//  HomeDataFetcher.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import Foundation

protocol HomeDataFetching {
    func fetchHome(lat: Double?, lon: Double?) async throws -> HomeResponse
}

extension HomeRequester: HomeDataFetching {}
