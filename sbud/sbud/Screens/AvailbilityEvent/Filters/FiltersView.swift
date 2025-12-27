//
//  FiltersView.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct FiltersView: View {
    var body: some View {
        ZStack{
            Color.backgroundColor
            VStack{
                Spacer()
                Wheel()
                    .offset(y: 120)
            }
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FiltersView()
}
