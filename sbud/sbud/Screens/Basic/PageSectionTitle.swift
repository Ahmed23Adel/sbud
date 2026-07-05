//
//  PageSectionTitle.swift
//  sbud
//
//  Created by Erdal on 5.07.2026.
//

import SwiftUI

struct PageSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .black))
            .foregroundColor(.white)
    }
}

