//
//  ImageUploadResponse.swift
//  sbud
//
//  Created by Erdal on 1.04.2026.
//

import Foundation

struct ImageUploadResponse: Codable {
    let url: String
    let filename: String
    let content_type: String
    let size_bytes: Int
}
