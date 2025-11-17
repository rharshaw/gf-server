//
//  ServerError.swift
//  GfServer
//
//  Created by Rian Harshaw on 11/15/25.
//

import Vapor

struct ServerError: Content, AbortError {
    var status: HTTPStatus
    var reason: String
    
    init(_ status: HTTPStatus, reason: String) {
        self.status = status
        self.reason = reason
    }
}

