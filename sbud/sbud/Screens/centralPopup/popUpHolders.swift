//
//  popUpHolders.swift
//  sbud
//
//  Created by ahmed on 04/02/2026.
//

import Foundation
import Combine
import UIKit

class PopUpInfo: Identifiable, ObservableObject {
    let id = UUID()
    let msg: String
    let type: centralPopupType
    @Published var isBeingDismissed = false
    
    init(msg: String, type: centralPopupType) {
        self.msg = msg
        self.type = type
    }
}

class PopUpGenerator: ObservableObject {
    static var shared = PopUpGenerator()
    @Published var popUps: [PopUpInfo] = []
    private let maxPopUps = 3
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private init() {}
    
    func show(msg: String, type: centralPopupType) {
        impactFeedback.impactOccurred(intensity: 0.9)
        let newPopUp = PopUpInfo(msg: msg, type: type)
        DispatchQueue.main.async {
            self.popUps.insert(newPopUp, at: 0)
            if self.popUps.count > self.maxPopUps {
                self.popUps.removeLast(self.popUps.count - self.maxPopUps)
            }
        }
    }
    
    func dismiss(_ popUp: PopUpInfo) {
        DispatchQueue.main.async {
            if let index = self.popUps.firstIndex(where: { $0.id == popUp.id }) {
                self.popUps.remove(at: index)
            }
        }
    }
    
    func clearAll() {
        DispatchQueue.main.async {
            self.popUps.removeAll()
        }
    }
}
