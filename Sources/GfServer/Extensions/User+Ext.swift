//
//  User+Ext.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Fluent
import Vapor

extension User {
    struct Create: Content {
        var username: String
        var password: String
        var confirmPassword: String
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, Field<String>> { \.$email }
    
    static var passwordHashKey: KeyPath<User, Field<String>> { \.$passwordHash }
    
    func verify(password: String) throws -> Bool {
           try Bcrypt.verify(password, created: self.passwordHash)
       }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}




