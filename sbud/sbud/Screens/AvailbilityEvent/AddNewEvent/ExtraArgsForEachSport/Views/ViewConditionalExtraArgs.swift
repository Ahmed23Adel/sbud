//
//  ViewConditionalExtraArgs.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewConditionalExtraArgs: View {
    @ObservedObject var argsHolder: NewEventExtraArgsHoder
    var body: some View {
        VStack{
            switch argsHolder.selectedActivity {
            case .running:
                ViewExtraArgsRunning(args: argsHolder.extraArgs as! ExtraArgsHolderRunning)
            case .cycling:
                ViewExtraArgsCycling(args: argsHolder.extraArgs as! ExtraArgsHolderCycling)
            case .gym:
                ViewExtraArgsGym(args: argsHolder.extraArgs as! ExtraArgsHolderGym)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .fixedSize(horizontal: false, vertical: true)
        
        
    }
}
//
//#Preview {
//    ViewConditionalExtraArgs(selectedActivity: .constant(.running), extraArgs: .constant([:]))
//}
