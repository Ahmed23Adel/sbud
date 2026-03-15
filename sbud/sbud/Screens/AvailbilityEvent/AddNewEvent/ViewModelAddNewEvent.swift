//
//  ViewModelAddNewEvent.swift
//  sbud
//
//  Created by ahmed on 05/03/2026.
//

import Foundation
import Combine
import _PhotosUI_SwiftUI
import FirebaseAuth



class ViewModelAddNewEvent: ObservableObject{
    @Published var selectedImgURL: String = "https://firebasestorage.googleapis.com/v0/b/sbud-e5bdd.firebasestorage.app/o/uploads%2Fkd5YqKdsHoeRelMwDgssF9xwE7H3%2Frun8.png?alt=media&token=c99a16df-fce1-4f98-81ea-f5e54f7903fb"
    
    @Published var orchestrator = NewEventOrchestrator()
    @Published var isLoading = false
   
    func submit(){
        isLoading = true
        let requestData = orchestrator.createRequestData()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(requestData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
        
        let requester = CreateNewEventRequester()
        Task{
            let _ = try await requester.createNewEvent(requestParams: requestData)
            await MainActor.run{
                isLoading = false
            }
        }
        
    }
}
