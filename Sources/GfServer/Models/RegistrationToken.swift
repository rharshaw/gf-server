//
//  RegistrationToken.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Fluent
import Vapor

final class RegistrationToken: Model, @unchecked Sendable {
    static let schema = "registration_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "expires_at")
    var expiresAt: Date?
    
    @OptionalParent(key: "address_code_id")
    var addressCode: AddressCode?
    
    init(){}
    
    init(value: String, expiresAt: Date?) {
        self.value = value
        self.expiresAt = expiresAt
    }
}
