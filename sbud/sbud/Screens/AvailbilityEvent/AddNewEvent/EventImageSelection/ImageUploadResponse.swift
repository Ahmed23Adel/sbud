//
//  ImageUploadResponse.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import Foundation

struct ImageUploadResponse: Codable {
    let url: String
    let filename: String
    let content_type: String
    let size_bytes: Int
}
