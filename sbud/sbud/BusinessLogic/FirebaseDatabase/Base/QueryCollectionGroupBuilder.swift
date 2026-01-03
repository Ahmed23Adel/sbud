//
//  QueryCollectionGroupBuilder.swift
//  sbud
//
//  Created by ahmed on 24/12/2025.
//

import Foundation
import FirebaseFirestore

struct QueryCollectionGroupBuilder: IQueryBuilder {
    private var filters: [Filter] = []
    private var limit: Int?
    private var orderBy: orderByAggregate?
    
    private var collectionGroupId: String
    private var firebaseClient: FirebaseClient
    
    init(collectionGroupId: String, firebaseClient: FirebaseClient) {
        self.collectionGroupId = collectionGroupId
        self.firebaseClient = firebaseClient
    }
    
    mutating func appendFilter(_ filter: Filter) -> Self {
        filters.append(filter)
        return self
    }
    
    mutating func setLimit(_ limit: Int) -> Self {
        self.limit = limit
        return self
    }
    
    mutating func setOrderBy(_ orderBy: orderByAggregate) -> Self {
        self.orderBy = orderBy
        return self
    }
    
    func build() -> Query {
        var query: Query = firebaseClient.db.collectionGroup(collectionGroupId)
        
        for filter in filters {
            query = buildWhereClause(query: query, filter: filter)
        }
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        if let orderBy = orderBy {
            query = query.order(by: orderBy.field, descending: orderBy.descending)
        }
        
        return query
    }
    
    private func buildWhereClause(query: Query, filter: Filter) -> Query {
        switch filter.operation {
        case .isEqualTo:
            return query.whereField(filter.field, isEqualTo: filter.value)
        case .isGreaterThan:
            return query.whereField(filter.field, isGreaterThan: filter.value)
        case .isLessThan:
            return query.whereField(filter.field, isLessThan: filter.value)
        case .isGreaterThanOrEqualTo:
            return query.whereField(filter.field, isGreaterThanOrEqualTo: filter.value)
        case .isLessThanOrEqualTo:
            return query.whereField(filter.field, isLessThanOrEqualTo: filter.value)
        case .arrayContains:
            return query.whereField(filter.field, arrayContains: filter.value)
        case .whereIn:
            // TODO: fix later plz
            return query
        }
    }
}
