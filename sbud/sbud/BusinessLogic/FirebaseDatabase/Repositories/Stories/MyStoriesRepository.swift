//
//  MyStoriesRepository.swift
//  sbud
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MyStoriesRepository: IFirebaesRepository {    
    typealias T = MyStoryDocument
    typealias Constants = MyStoriesRepositoryConstants

    let collectionPath = "stories"
    let firebaseClient = FirebaseClient()
    let constants = MyStoriesRepositoryConstants()
    private let db = Firestore.firestore()

    func fetch(query: any IQueryBuilder) async throws -> [MyStoryDocument] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: MyStoryDocument.self) }
    }

    func fetchById(_ id: String) async throws -> MyStoryDocument? {
        let doc = try await db.collection(collectionPath).document(id).getDocument()
        return try? doc.data(as: MyStoryDocument.self)
    }

    func fetchByIds(_ ids: [String]) async throws -> [MyStoryDocument]? {
        return []
    }

    @discardableResult
    func create(_ item: MyStoryDocument) async throws -> String {
        let docRef = db.collection(collectionPath).document()
        try docRef.setData(from: item)
        return docRef.documentID
    }

    func update(_ id: String, _ item: MyStoryDocument) async throws {}

    func delete(_ id: String) async throws {
        try await db.collection(collectionPath).document(id).delete()
    }

    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }

    // MARK: - Domain-specific

    /// Fetches up to `limit` stories created by the current user, picks random images.
    func fetchMyRandomImages(limit: Int = 5) async throws -> [MyStoryImageCard] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let snapshot = try await db.collection(collectionPath)
            .whereField(constants.userId, isEqualTo: uid)
            .order(by: constants.createdAt, descending: true)
            .limit(to: 20)
            .getDocuments()

        let docs = snapshot.documents.compactMap { try? $0.data(as: MyStoryDocument.self) }

        // Flatten all images across stories, carry the reactions + text from their parent story
        var allCards: [MyStoryImageCard] = []
        for doc in docs {
            for url in doc.images {
                allCards.append(MyStoryImageCard(
                    imageUrl: url,
                    reactions: doc.reactions,
                    caption: doc.text
                ))
            }
        }

        allCards.shuffle()
        return Array(allCards.prefix(limit))
    }
}

struct MyStoryImageCard: Identifiable {
    let id = UUID()
    let imageUrl: String
    let reactions: [String: String]
    let caption: String?
}
