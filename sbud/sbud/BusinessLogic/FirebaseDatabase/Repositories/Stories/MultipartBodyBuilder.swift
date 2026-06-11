//
//  MultipartBodyBuilder.swift
//  sbud
//

import Foundation

struct MultipartBodyBuilder {
    let boundary: String

    init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }

    func build(eventId: String?, text: String?, images: [Data]) -> Data {
        var body = Data()
        if let eventId {
            body.appendFormField(name: "eventId", value: eventId, boundary: boundary)
        }
        if let text, !text.isEmpty {
            body.appendFormField(name: "text", value: text, boundary: boundary)
        }
        for (i, imageData) in images.enumerated() {
            body.appendFileField(
                name: "images",
                filename: "photo\(i).jpg",
                data: imageData,
                mimeType: "image/jpeg",
                boundary: boundary
            )
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

private extension Data {
    mutating func appendFormField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }

    mutating func appendFileField(name: String, filename: String, data fileData: Data, mimeType: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(fileData)
        append("\r\n".data(using: .utf8)!)
    }
}
