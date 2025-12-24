//
//  IQueryCollectionBuilder.swift
//  sbud
//
//  Created by ahmed on 24/12/2025.
//

import Foundation
import FirebaseFirestore

protocol IQueryBuilder {
    mutating func appendFilter(_ filter: Filter) -> Self
    mutating func setLimit(_ limit: Int) -> Self
    mutating func setOrderBy(_ orderBy: orderByAggregate) -> Self
    func build() -> Query
}
