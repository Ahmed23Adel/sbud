//
//  MultipartBodyBuilderTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
@testable import sbud

final class MultipartBodyBuilderTests: XCTestCase {

    private let boundary = "TEST_BOUNDARY"

    private func bodyString(eventId: String?, text: String?, images: [Data]) -> String {
        let builder = MultipartBodyBuilder(boundary: boundary)
        let data = builder.build(eventId: eventId, text: text, images: images)
        return String(decoding: data, as: UTF8.self)
    }

    func test_build_withEventIdAndText_containsBothFields() {
        let result = bodyString(eventId: "event_42", text: "ciao", images: [])

        XCTAssertTrue(result.contains("name=\"eventId\"\r\n\r\nevent_42\r\n"))
        XCTAssertTrue(result.contains("name=\"text\"\r\n\r\nciao\r\n"))
    }

    func test_build_nilEventId_omitsEventIdField() {
        let result = bodyString(eventId: nil, text: "ciao", images: [])
        XCTAssertFalse(result.contains("name=\"eventId\""))
    }

    func test_build_emptyText_omitsTextField() {
        let result = bodyString(eventId: "e1", text: "", images: [])
        XCTAssertFalse(result.contains("name=\"text\""))
    }

    func test_build_images_containsFileFieldsWithCorrectFilenames() {
        let img = "fake_jpeg_bytes".data(using: .utf8)!
        let result = bodyString(eventId: nil, text: nil, images: [img, img])

        XCTAssertTrue(result.contains("filename=\"photo0.jpg\""))
        XCTAssertTrue(result.contains("filename=\"photo1.jpg\""))
        XCTAssertTrue(result.contains("Content-Type: image/jpeg"))
        XCTAssertTrue(result.contains("fake_jpeg_bytes"))
    }

    func test_build_alwaysEndsWithClosingBoundary() {
        let result = bodyString(eventId: nil, text: nil, images: [])
        XCTAssertTrue(result.hasSuffix("--TEST_BOUNDARY--\r\n"))
    }
}