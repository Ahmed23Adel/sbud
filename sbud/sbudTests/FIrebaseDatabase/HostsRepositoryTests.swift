//
//  HostsRepositoryTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//

import XCTest
import FirebaseFirestore
@testable import sbud

final class HostsRepositoryTests: XCTestCase {
    
    private var savedProfile: UserProfile?

    override func setUp() {
        super.setUp()
        savedProfile = ProfileManager.shared.getLocalProfile()
        ProfileManager.shared.saveProfileToLocale(profile: UserProfile(id: "test_user_id"))
    }

    override func tearDown() {
        if let savedProfile {
            ProfileManager.shared.saveProfileToLocale(profile: savedProfile)
        } else {
            ProfileManager.shared.deleteProfileFromLocale()
        }
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_hostsRepository_init_setsCorrectCollectionPath() {
        // Arrange (Prepariamo i dati)
        let sampleEventId = "12345_evento_test"
        
        // Act (Inizializziamo il repository)
        let repository = HostsRepository(eventId: sampleEventId)
        
        // Assert (Verifichiamo che la stringa del percorso sia costruita esattamente come previsto)
        // Il tuo codice fa: collectionPath = "\(collectionPath)/\(eventId)/hosts" dove la base è "Events"
        let expectedPath = "Events/\(sampleEventId)/hosts"
        
        XCTAssertEqual(repository.collectionPath, expectedPath, "Il percorso della collezione deve essere formattato correttamente usando l'eventId inserito")
    }
    
    func test_hostsRepository_init_setsCorrectProperties() {
        // Arrange & Act
        let sampleEventId = "abcde_event"
        let repository = HostsRepository(eventId: sampleEventId)
        
        // Assert
        XCTAssertEqual(repository.eventId, sampleEventId)
        XCTAssertEqual(repository.userId, "test_user_id", "Il repository deve recuperare correttamente l'ID dell'utente dal profilo locale")
    }
    
}
