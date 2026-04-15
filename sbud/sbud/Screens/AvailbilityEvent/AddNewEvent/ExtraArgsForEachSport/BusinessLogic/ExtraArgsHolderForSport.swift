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
    func areFieldsValid() -> Bool
}

@Observable
class ExtraArgsHolderRunning: ExtraArgsHolderForSport{
    var proposedDistance = 6.0
    var propsosedPace = 8.30
    
    func createEncodableRequest() -> any RequestActivityDetails {
        RequestActivityDetailsRunning(targetDistanceInKm: proposedDistance, targetPace: propsosedPace)
    }
    
    func areFieldsValid() -> Bool {
        if proposedDistance > 0 && propsosedPace > 0{
            return true
        }
        return false
    }
}
@Observable
class ExtraArgsHolderCycling: ExtraArgsHolderForSport{
    var proposedPowerInWatt = 200.0
    var proposedCadenceInRPM = 80.0
    
    func createEncodableRequest() -> any RequestActivityDetails {
        RequestActivityDetailsCycling(
            powerInWatt: proposedPowerInWatt,
            cadenceInRPM: proposedCadenceInRPM)
    }
    
    func areFieldsValid() -> Bool {
        if proposedPowerInWatt > 0 && proposedCadenceInRPM > 0{
            return true
        }
        return false
    }
}
@Observable
class ExtraArgsHolderGym: ExtraArgsHolderForSport{
    var proposedDayType = GymDayType.push
    
    func createEncodableRequest() -> any RequestActivityDetails {
        RequestActivityDetailsGym(dayTyp: proposedDayType)
    }
    func areFieldsValid() -> Bool {
        return true
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
    
    
    func areFieldsValid() -> Bool {
        self.extraArgs.areFieldsValid()
    }
}

