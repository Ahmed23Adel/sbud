//
//  Loading.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI
import Lottie

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
                .opacity(0.9)

            VStack {
                LottieView(animation: .named("JoggingLoading"))
                    .playing()
                    .looping()
                    .frame(width: 300, height: 300)
                
                Text("Loading...")
                    .font(.title)
                    .foregroundColor(.mainColor)
            }

        }
    }
}

#Preview {
    LoadingView()
}
