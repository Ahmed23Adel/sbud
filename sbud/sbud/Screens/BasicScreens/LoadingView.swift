//
//  Loading.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            VStack {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(Color.mainColor)
                    .foregroundColor(Color.mainColor)
            }

        }
    }
}

#Preview {
    LoadingView()
}
