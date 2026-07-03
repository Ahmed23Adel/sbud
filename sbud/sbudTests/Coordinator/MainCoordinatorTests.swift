//
//  MainCoordinatorTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 02/07/2026.
//

import XCTest
import Combine
import FirebaseAuth
@testable import sbud // Sostituisci con il nome corretto del tuo target se diverso

@MainActor
final class MainCoordinatorTests: XCTestCase {
    
    var sut: MainCoordinator!
    var mockAuthManager: MockAuthenticationManager!
    var mockProfileManager: MockProfileServiceManager!
    
    override func setUp() {
        super.setUp()
        // Inizializziamo i nostri finti servizi (Mock)
        mockAuthManager = MockAuthenticationManager()
        mockProfileManager = MockProfileServiceManager()
        
        // Iniettiamo i mock nel coordinatore da testare
        sut = MainCoordinator(authService: mockAuthManager, profileService: mockProfileManager)
    }
    
    override func tearDown() {
        sut = nil
        mockAuthManager = nil
        mockProfileManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests Navigazione Base
    
    func test_init_startsInLoadingRoute() {
        // Verifica che all'avvio l'app sia correttamente nello stato di caricamento
        XCTAssertEqual(sut.currentRoute, .loading)
    }
    
    func test_navigateTo_changesRouteCorrectly() {
        sut.navigateTo(.signIn)
        XCTAssertEqual(sut.currentRoute, .signIn)
    }
    
    func test_goToHome_navigatesToHome() {
        sut.goToHome()
        XCTAssertEqual(sut.currentRoute, .home)
    }
    
    // MARK: - Tests Risoluzione Route Iniziale
    
    func test_resolveInitialRoute_whenUserNotAuthenticated_navigatesToSignUp() async throws {
        // Arrange: L'utente non è loggato
        mockAuthManager.authStatusReturnValue = false
        
        // Act: Chiediamo al coordinatore di decidere la schermata iniziale
        sut.resolveInitialRoute()
        
        // Nota: Poiché resolveInitialRoute lancia un Task asincrono non strutturato,
        // attendiamo qualche millisecondo per consentire il cambio di stato della Route.
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert: Ci aspettiamo che vada alla schermata di registrazione
        XCTAssertEqual(sut.currentRoute, .signUp)
    }
    
    func test_resolveInitialRoute_whenAuthenticatedAndProfileComplete_navigatesToHome() async throws {
        // Arrange: Utente loggato e profilo già configurato completato
        mockAuthManager.authStatusReturnValue = true
        mockProfileManager.isProfileSetupCompleteReturnValue = true
        
        // Act
        sut.resolveInitialRoute()
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert
        XCTAssertEqual(sut.currentRoute, .home)
    }
    
    func test_resolveInitialRoute_whenAuthenticatedAndProfileIncomplete_syncSucceeds_navigatesToHome() async throws {
        // Arrange: Utente loggato ma profilo locale incompleto
        mockAuthManager.authStatusReturnValue = true
        mockProfileManager.isProfileSetupCompleteReturnValue = false
        
        // Simuliamo che durante il sync il profilo venga scaricato e completato con successo
        mockProfileManager.onSyncProfile = { [weak self] in
            self?.mockProfileManager.isProfileSetupCompleteReturnValue = true
        }
        
        // Act
        sut.resolveInitialRoute()
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert
        XCTAssertTrue(mockProfileManager.syncProfileAfterLoginCalled)
        XCTAssertEqual(sut.currentRoute, .home)
    }
    
    func test_resolveInitialRoute_whenAuthenticatedAndProfileIncomplete_syncFails_navigatesToProfileSetup() async throws {
        // Arrange: Utente loggato, profilo incompleto e il sync fallisce (lancia un errore)
        struct DummyError: Error {}
        mockAuthManager.authStatusReturnValue = true
        mockProfileManager.isProfileSetupCompleteReturnValue = false
        mockProfileManager.syncProfileAfterLoginError = DummyError()
        
        // Act
        sut.resolveInitialRoute()
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert
        XCTAssertTrue(mockProfileManager.syncProfileAfterLoginCalled)
        XCTAssertEqual(sut.currentRoute, .profileSetup)
    }
    
    // MARK: - Tests Eventi di Autenticazione (Delegate)
    
    func test_coordinatorDidRequestLogout_clearsLocaleAndSignsOut() async throws {
        // Act: Simuliamo la richiesta di logout
        sut.coordinatorDidRequestLogout()
        
        // Assert immediato: Il profilo locale deve essere cancellato e la route deve andare a signUp
        XCTAssertTrue(mockProfileManager.deleteProfileFromLocaleCalled)
        XCTAssertEqual(sut.currentRoute, .signUp)
        
        // Attendiamo l'esecuzione del Task interno asincrono per il signOut di Firebase
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(mockAuthManager.signOutCalled)
    }
}

class MockAuthenticationManager: IAuthenticationManager {
    // Proprietà richieste dal protocollo
    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User? = nil
    
    // Variabili per i nostri test
    var authStatusReturnValue = false
    var signOutCalled = false
    var signOutError: Error?
    
    func checkAuthStatus() -> Bool {
        return authStatusReturnValue
    }
    
    func signOut() async throws {
        signOutCalled = true
        if let error = signOutError {
            throw error
        }
    }
    
    // Metodi dummy (vuoti) richiesti dal protocollo, ma che non ci servono per questi specifici test
    func signIn() async throws {}
    func signUp() async throws {}
    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
}

class MockProfileServiceManager: IProfileServiceManager {
    // Proprietà richieste dal protocollo
    var isProfileSetupCompleteReturnValue = false
    var isProfileSetupComplete: Bool {
        return isProfileSetupCompleteReturnValue
    }
    
    // Variabili per i nostri test
    var syncProfileAfterLoginCalled = false
    var syncProfileAfterLoginError: Error?
    var deleteProfileFromLocaleCalled = false
    var onSyncProfile: (() -> Void)?
    
    func syncProfileAfterLogin() async throws {
        syncProfileAfterLoginCalled = true
        onSyncProfile?()
        if let error = syncProfileAfterLoginError {
            throw error
        }
    }
    
    func deleteProfileFromLocale() {
        deleteProfileFromLocaleCalled = true
    }
    
    // Metodi dummy (vuoti) richiesti dal protocollo
    func saveProfileToDatabase(profile: UserProfile) async throws {}
    func deleteProfileFromDatabase(uid: String) async throws {}
    func saveProfileToLocale(profile: UserProfile) {}
}
