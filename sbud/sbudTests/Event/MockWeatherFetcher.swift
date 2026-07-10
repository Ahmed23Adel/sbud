//
//  MockWeatherFetcher.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 10/07/2026.
//


import XCTest
@testable import sbud

final class MockWeatherFetcher: WeatherFetching {
    var dataToReturn: Data = Data()
    var shouldThrow = false
    private(set) var lastURL: URL?

    func fetchData(from url: URL) async throws -> Data {
        lastURL = url
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return dataToReturn
    }
}

final class WeatherViewModelTests: XCTestCase {

    private var fetcher: MockWeatherFetcher!

    override func setUp() {
        super.setUp()
        fetcher = MockWeatherFetcher()
    }

    // MARK: - clampEnd

    func test_clampEnd_withinDay_returnsEnd() {
        let start = Date(timeIntervalSince1970: 0)
        let end = start.addingTimeInterval(3600 * 5)
        XCTAssertEqual(WeatherViewModel.clampEnd(end, from: start), end)
    }

    func test_clampEnd_beyondDay_capsAt24h() {
        let start = Date(timeIntervalSince1970: 0)
        let end = start.addingTimeInterval(86400 * 3)
        XCTAssertEqual(WeatherViewModel.clampEnd(end, from: start),
                       start.addingTimeInterval(86400))
    }

    func test_clampEnd_exactly24h_returnsEnd() {
        let start = Date(timeIntervalSince1970: 0)
        let end = start.addingTimeInterval(86400)
        XCTAssertEqual(WeatherViewModel.clampEnd(end, from: start), end)
    }

    // MARK: - buildURLString

    func test_buildURLString_containsAllComponents() {
        let url = WeatherViewModel.buildURLString(lat: 45.5, lon: 9.2,
                                                  startStr: "2026-07-01", endStr: "2026-07-02")
        XCTAssertTrue(url.hasPrefix("https://api.open-meteo.com/v1/forecast?"))
        XCTAssertTrue(url.contains("latitude=45.5"))
        XCTAssertTrue(url.contains("longitude=9.2"))
        XCTAssertTrue(url.contains("start_date=2026-07-01"))
        XCTAssertTrue(url.contains("end_date=2026-07-02"))
        XCTAssertTrue(url.contains("timeformat=unixtime"))
        XCTAssertNotNil(URL(string: url), "La stringa deve essere un URL valido")
    }

    // MARK: - parseData

    private func makeJSON(times: [TimeInterval],
                          temps: [Double?]? = nil,
                          precip: [Double?]? = nil,
                          codes: [Double?]? = nil,
                          wind: [Double?]? = nil) -> Data {
        var hourly: [String: Any] = ["time": times]
        if let temps { hourly["temperature_2m"] = temps.map { $0 as Any } }
        if let precip { hourly["precipitation_probability"] = precip.map { $0 as Any } }
        if let codes { hourly["weathercode"] = codes.map { $0 as Any } }
        if let wind { hourly["windspeed_10m"] = wind.map { $0 as Any } }
        return try! JSONSerialization.data(withJSONObject: ["hourly": hourly])
    }

    func test_parseData_mapsAllFields() throws {
        let data = makeJSON(times: [1000, 2000],
                            temps: [21.5, 19.0],
                            precip: [10, 80],
                            codes: [0, 61],
                            wind: [5.5, 12.0])

        let slices = try WeatherViewModel.parseData(data)

        XCTAssertEqual(slices.count, 2)
        XCTAssertEqual(slices[0].time, Date(timeIntervalSince1970: 1000))
        XCTAssertEqual(slices[0].temp, 21.5)
        XCTAssertEqual(slices[0].precipProb, 10)
        XCTAssertEqual(slices[1].code, 61)
        XCTAssertEqual(slices[1].wind, 12.0)
    }

    func test_parseData_missingOptionalArrays_defaultsToZero() throws {
        let data = makeJSON(times: [1000])

        let slices = try WeatherViewModel.parseData(data)

        XCTAssertEqual(slices.count, 1)
        XCTAssertEqual(slices[0].temp, 0)
        XCTAssertEqual(slices[0].precipProb, 0)
        XCTAssertEqual(slices[0].wind, 0)
    }

    func test_parseData_invalidJSON_throws() {
        let data = "non è json".data(using: .utf8)!
        XCTAssertThrowsError(try WeatherViewModel.parseData(data))
    }

    func test_parseData_emptyTimes_returnsEmpty() throws {
        let data = makeJSON(times: [])
        XCTAssertTrue(try WeatherViewModel.parseData(data).isEmpty)
    }

    // MARK: - load (end-to-end del VM col mock)

    func test_load_success_populatesSlices() async {
        fetcher.dataToReturn = makeJSON(times: [1000], temps: [25.0],
                                        precip: [0], codes: [0], wind: [3.0])
        let sut = WeatherViewModel(fetcher: fetcher)

        await sut.load(lat: 45.0, lon: 9.0,
                       start: Date(timeIntervalSince1970: 0),
                       end: Date(timeIntervalSince1970: 3600))

        XCTAssertEqual(sut.slices.count, 1)
        XCTAssertEqual(sut.slices.first?.temp, 25.0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }

    func test_load_clampsEndDateInRequestedURL() async {
        fetcher.dataToReturn = makeJSON(times: [])
        let sut = WeatherViewModel(fetcher: fetcher)
        let start = Date(timeIntervalSince1970: 0) // 1970-01-01

        await sut.load(lat: 1, lon: 1, start: start,
                       end: start.addingTimeInterval(86400 * 5))

        let url = fetcher.lastURL?.absoluteString ?? ""
        XCTAssertTrue(url.contains("end_date=1970-01-02"),
                      "L'end date deve essere clampata a +24h, era: \(url)")
    }

    func test_load_fetcherThrows_setsError() async {
        fetcher.shouldThrow = true
        let sut = WeatherViewModel(fetcher: fetcher)

        await sut.load(lat: 1, lon: 1, start: Date(), end: Date())

        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.slices.isEmpty)
    }

    func test_load_invalidData_setsError() async {
        fetcher.dataToReturn = "garbage".data(using: .utf8)!
        let sut = WeatherViewModel(fetcher: fetcher)

        await sut.load(lat: 1, lon: 1, start: Date(), end: Date())

        XCTAssertNotNil(sut.error)
    }
}
