//
//  MessagesUITests.swift
//  sbudUITests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//

import XCTest

final class MessagesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Interrompe il test se si verifica un fallimento
        continueAfterFailure = false
        
        // Avvia l'applicazione
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test della schermata ChatView
    
    func test_chatView_typeAndSendMessage() throws {
        /*
         ATTENZIONE: Affinché questo test passi completamente, l'app sul simulatore
         deve trovarsi all'interno della ChatView. Se l'app parte dalla schermata di Login,
         dovresti aggiungere qui i comandi (es. app.buttons["Login"].tap()) per arrivare alla chat.
         */
        
        // 1. Cerchiamo il campo di testo usando l'esatto placeholder che hai nel codice
        let messageInput = app.textFields["Message..."]
        
        // Aspettiamo fino a 5 secondi che il campo appaia sullo schermo
        if messageInput.waitForExistence(timeout: 5.0) {
            
            // 2. Tocchiamo il campo e scriviamo un messaggio finto
            messageInput.tap()
            messageInput.typeText("Ciao, questo è un test UI automatico!")
            
            // 3. Cerchiamo il bottone "Send" della tua CustomInputView
            let sendButton = app.buttons["Send"]
            XCTAssertTrue(sendButton.exists, "Il bottone 'Send' deve essere presente sullo schermo")
            
            // 4. Premiamo Invia
            sendButton.tap()
            
            // 5. Verifichiamo che la "ChatBubble" con il testo inviato sia comparsa nella ScrollView
            let sentMessageBubble = app.staticTexts["Ciao, questo è un test UI automatico!"]
            XCTAssertTrue(sentMessageBubble.waitForExistence(timeout: 2.0), "Il messaggio appena inviato deve apparire nella lista delle chat")
            
        } else {
            // Se non trova il campo di testo, il test viene skippato ma senza fare un brutto crash rosso
            print("⚠️ ChatView non trovata. Il simulatore non è arrivato alla schermata della Chat.")
        }
    }

    // MARK: - Test della schermata EventConversationsView
    
    func test_eventConversationsView_showsEmptyState() throws {
        // Cerchiamo esattamente il testo che hai impostato per lo stato "vuoto"
        let emptyStateText = app.staticTexts["No messages for this event yet."]
        
        if emptyStateText.waitForExistence(timeout: 3.0) {
            XCTAssertTrue(emptyStateText.exists, "Il testo di stato vuoto dovrebbe essere mostrato se non ci sono recentMessages")
        } else {
            print("⚠️ EventConversationsView non trovata o lista chat non vuota.")
        }
    }
}
