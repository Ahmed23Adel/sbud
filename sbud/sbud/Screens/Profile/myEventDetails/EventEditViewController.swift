//
//  EventEditViewController.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 17/05/2026.
//


import SwiftUI
import EventKit
import EventKitUI

//  Wrapper per EventKitUI in SwiftUI
struct EventEditViewController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let eventStore: EKEventStore
    let event: EKEvent

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let vc = EKEventEditViewController()
        vc.eventStore = eventStore
        vc.event = event
        vc.editViewDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: EventEditViewController

        init(_ parent: EventEditViewController) {
            self.parent = parent
        }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
