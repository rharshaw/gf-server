//
//  ServerError.swift
//  GfServer
//
//  Created by Rian Harshaw on 11/17/25.
//

import Vapor

struct ServerError: AbortError {
    var status: HTTPStatus
    var reason: String
    
    init(_ status: HTTPStatus, reason: String) {
        self.status = status
        self.reason = reason
    }
}
