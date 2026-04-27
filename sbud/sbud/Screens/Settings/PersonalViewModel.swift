//
//  PersonalViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/03/26.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine
import FirebaseAuth

@MainActor
class PersonalViewModel: ObservableObject {
    @Published var myEvents: [AvailabilityEvent] = []
    @Published var isLoading: Bool = false
    
    
    func fetchMyEvents() async {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print(" AUTH ERROR: No user currently logged into Firebase Auth!")
            return
        }
        
        print("AUTH OK: Searching for events for user with UID: \(currentUid)")
        isLoading = true
        let db = Firestore.firestore()
        
        do {
            
            let snapshot = try await db.collection("Events")
                .whereField("creatorId", isEqualTo: currentUid)
                .getDocuments()
            
            print("FOUND \(snapshot.documents.count) DOCUMENTS on Firestore for this user.")
            
            self.myEvents = snapshot.documents.compactMap { doc -> AvailabilityEvent? in
                let data = doc.data()
                print("   ➜ Analyzing document ID: \(doc.documentID)")
                
                let eventId = data["eventId"] as? String ?? "NoEventId12"
                let creatorId = data["creatorId"] as? String ?? "No creatorId found"
                let activityType = data["activityType"] as? String ?? "Unknown"
                print("      - CreatorId in doc: \(creatorId) | Activity: \(activityType)")
                
                let eventImage = data["eventImage"] as? String ?? ""
                let dateLocationId = data["dateLocationId"] as? String ?? ""
                
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                let startDateTime = (data["startDateTime"] as? Timestamp)?.dateValue() ?? Date()
                let endDateTime = (data["endDateTime"] as? Timestamp)?.dateValue() ?? Date()
                
                let mainGeoPoint = data["geoPoint"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                
                let gData = data["g"] as? [String: Any] ?? [:]
                let geohash = gData["geohash"] as? String ?? ""
                
                var coordinate = Coordinate(latitude: 0.0, longitude: 0.0)
                if let fbGeoPoint = gData["geopoint"] as? GeoPoint {
                    coordinate = Coordinate(latitude: fbGeoPoint.latitude, longitude: fbGeoPoint.longitude)
                } else if let coordDict = gData["geopoint"] as? [String: Double] {
                    coordinate = Coordinate(latitude: coordDict["latitude"] ?? 0.0, longitude: coordDict["longitude"] ?? 0.0)
                }
                
                let myGeoLocation = GeoLocation(geopoint: coordinate, geohash: geohash)
                
                return AvailabilityEvent(
                    id: doc.documentID,
                    eventId: eventId,
                    geoPoint: mainGeoPoint,
                    dateLocationId: dateLocationId,
                    activityType: activityType,
                    startDateTime: startDateTime,
                    endDateTime: endDateTime,
                    createdAt: createdAt,
                    g: myGeoLocation,
                    isDateConfirmed: data["isDateConfirmed"] as? Bool ?? false,
                    isLocationConfirmed: data["isLocationConfirmed"] as? Bool ?? false,
                    isPublic: data["isPublic"] as? Bool ?? true,
                    eventImage: eventImage,
                    creatorName: creatorId
                )
            }
            
            self.isLoading = false
            print("MAPPING COMPLETED: Showing \(self.myEvents.count) events in the list.")
            
        } catch {
            print(" FIRESTORE ERROR: Failed to fetch data. Reason: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
}
