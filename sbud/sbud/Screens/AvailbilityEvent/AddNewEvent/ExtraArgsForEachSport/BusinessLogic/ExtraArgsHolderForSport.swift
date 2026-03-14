//
//  ExtraEventReturnables.swift
//  sbud
//
//  Created by ahmed on 14/03/2026.
//

import Foundation
import Combine

protocol ExtraArgsHolderForSport: ObservableObject{}

class ExtraArgsHolderRunning: ExtraArgsHolderForSport{
    @Published var proposedDistance = "6.0"
    @Published var propsosedPace = "8.30"
}

class ExtraArgsHolderCycling: ExtraArgsHolderForSport{
    @Published var proposedPowerInWatt = "200"
    @Published var proposedCadenceInRPM = "80"
}

class ExtraArgsHolderGym: ExtraArgsHolderForSport{
    @Published var proposedDayType = GymDayTypes.push
}

class NewEventExtraArgsHoder: ObservableObject{
    @Published var selectedActivity: ActivityType = .running {
        didSet{
            updateExtraArgs()
        }
    }
    @Published var extraArgs: any ExtraArgsHolderForSport = ExtraArgsHolderRunning()
    
    func updateExtraArgs(){
        switch self.selectedActivity {
        case .running:
            self.extraArgs = ExtraArgsHolderRunning()
        case .cycling:
            self.extraArgs = ExtraArgsHolderCycling()
        case .gym:
            self.extraArgs = ExtraArgsHolderGym()
        }
    }
    
    
}

