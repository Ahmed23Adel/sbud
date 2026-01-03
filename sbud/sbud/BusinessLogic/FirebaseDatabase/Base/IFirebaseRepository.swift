//
//  IFirebaseRepository.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

protocol IFirebaesRepository {
    associatedtype T
    associatedtype Constants: IRepositoryConstants
    
    var collectionPath: String { get  }
    var firebaseClient: FirebaseClient { get }
    var constants: Constants { get}
    
    func fetch (query: IQueryBuilder) async throws -> [T]
    func fetchById(_ id: String) async throws -> T?
    func fetchByIds(_ ids: [String]) async throws -> [T]?
    func create(_ item: T) async throws -> String
    func update(_ id: String, _ item: T) async throws
    func delete(_ id: String) async throws
    
    func initQueryBuilderObject() -> IQueryBuilder
 }
