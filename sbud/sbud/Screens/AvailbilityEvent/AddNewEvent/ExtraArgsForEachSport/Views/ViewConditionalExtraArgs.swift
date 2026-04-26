//
//  ViewConditionalExtraArgs.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI


// TODO: Implment new ViewExtraArgsX
struct ViewConditionalExtraArgs: View {
    @Bindable var argsHolder: ExtraArgsHolder

    var body: some View {
        VStack {
            switch argsHolder.selectedActivity {
            case .running:
                ViewExtraArgsRunning(args: argsHolder.extraArgs as! ExtraArgsHolderRunning)
            case .cycling:
                ViewExtraArgsCycling(args: argsHolder.extraArgs as! ExtraArgsHolderCycling)
            case .gym:
                ViewExtraArgsGym(args: argsHolder.extraArgs as! ExtraArgsHolderGym)
            case .skiing:
                ViewExtraArgsSkiing(args: argsHolder.extraArgs as! ExtraArgsHolderSkiing)
            case .swimming:
                ViewExtraArgsSwimming(args: argsHolder.extraArgs as! ExtraArgsHolderSwimming)
            case .hiking:
                ViewExtraArgsHiking(args: argsHolder.extraArgs as! ExtraArgsHolderHiking)
            case .yoga:
                ViewExtraArgsYoga(args: argsHolder.extraArgs as! ExtraArgsHolderYoga)
            case .tennis:
                ViewExtraArgsTennis(args: argsHolder.extraArgs as! ExtraArgsHolderTennis)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .fixedSize(horizontal: false, vertical: true)
    }
}


#Preview {
    ViewConditionalExtraArgs(argsHolder: ExtraArgsHolder())
}
