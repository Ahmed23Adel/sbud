//
//  BracketCorner.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI

struct BracketCorner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Rectangle()
                    .fill(Color("palelime"))
                    .frame(width: 3, height: 28)
                Rectangle()
                    .fill(Color("palelime"))
                    .frame(width: 25, height: 3)
            }
        }
        .frame(width: 28, height: 28, alignment: .topLeading)
    }
}

#Preview {
    BracketCorner()
}
