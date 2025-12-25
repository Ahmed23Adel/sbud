//
//  UserRepository.swift
//  sbud
//
//  Created by ahmed on 25/12/2025.
// ownerProfilePicture
import Foundation


class UserRepository: IFirebaesRepository{
    typealias T = IOtherUser
    
    let collectionPath: String = "users"
    let firebaseClient = FirebaseClient ()
    let constants = UserRepositoryConstants()
    
    
    
    func fetch(query: any IQueryBuilder) async throws -> [any T] {
        return  []
    }
    
    func fetchById(_ id: String) async throws -> (any T)? {
        return nil
    }
    
    func fetchByIds(_ ids: [String]) async throws -> [any T]? {
        guard !ids.isEmpty else { return [] }
        return []
    }
    
    func create(_ item: any T) async throws -> String {
        return ""
    }
    
    func update(_ id: String, _ item: any T) async throws {
    
    }
        
    func delete(_ id: String) async throws {
    }
    
    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }
    
    
}
