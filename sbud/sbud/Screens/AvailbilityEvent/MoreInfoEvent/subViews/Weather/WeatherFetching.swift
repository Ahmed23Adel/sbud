//
//  WeatherFetching.swift
//  sbud
//

import Foundation

protocol WeatherFetching {
    func fetchData(from url: URL) async throws -> Data
}

struct URLSessionWeatherFetcher: WeatherFetching {
    let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func fetchData(from url: URL) async throws -> Data {
        let (data, _) = try await session.data(from: url)
        return data
    }
}
