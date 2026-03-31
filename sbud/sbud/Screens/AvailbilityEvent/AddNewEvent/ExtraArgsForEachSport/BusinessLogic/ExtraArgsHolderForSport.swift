//
//  ExtraEventReturnables.swift
//  sbud
//
//  Created by ahmed on 14/03/2026.
//

import Foundation
import Combine


protocol ExtraArgsHolderForSport: Encodable{
    
    func createEncodableRequest() -> RequestActivityDetails
}

@Observable
class ExtraArgsHolderRunning: ExtraArgsHolderForSport{
    var proposedDistance = "6.0"
    var propsosedPace = "8.30"
    
    func createEncodableRequest() -> any RequestActivityDetails {
        RequestActivityDetailsRunning(targetDistanceInKm: Double(proposedDistance)!, targetPace: Double(propsosedPace)!)
    }
}
@Observable
class ExtraArgsHolderCycling: ExtraArgsHolderForSport{
    var proposedPowerInWatt = "200"
    var proposedCadenceInRPM = "80"
    
    func createEncodableRequest() -> any RequestActivityDetails {
        RequestActivityDetailsCycling(
            powerInWatt: Double(proposedPowerInWatt)!,
            cadenceInRPM: Double(proposedCadenceInRPM)!)
           
    }
}
@Observable
class ExtraArgsHolderGym: ExtraArgsHolderForSport{
    var proposedDayType = GymDayType.push
    
    func createEncodableRequest() -> any RequestActivityDetails {
        RequestActivityDetailsGym(dayTyp: proposedDayType)
    }
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

