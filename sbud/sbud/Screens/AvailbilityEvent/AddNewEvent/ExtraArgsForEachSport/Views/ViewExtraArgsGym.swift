//
//  ExtraArgsGym.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewExtraArgsGym: View {
    @Bindable var args: ExtraArgsHolderGym

    var body: some View {
        VStack(spacing: 16) {
            TextOptionSelector(
                header: "Day Type",
                selected: $args.proposedDayType
            )
        }
    }
}

#Preview {
    ViewExtraArgsGym(args: ExtraArgsHolderGym())
}
