//
//  SearchEventRequesting.swift
//  sbud
//

import Foundation

protocol SearchEventRequesting {
    func search(requestType: SearchEventRequestType) async throws -> SearchEventResponse
}

extension SearchEventRequester: SearchEventRequesting {}
