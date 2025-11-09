//
//  RegistrationTokenMiddleware.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Vapor
import Fluent

struct RegistrationTokenMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        
        guard let tokenValue = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Missing registration token")
        }
        
        guard let token = try await RegistrationToken.query(on: req.db)
            .filter(\.$value == tokenValue)
            .first(),
              let expiry = token.expiresAt, expiry > Date() else {
            throw Abort(.unauthorized, reason: "Invalid or expired registration token")
        }
        
        req.storage[RegistrationTokenStorageKey.self] = token
        
        return try await next.respond(to: req)
    }
}

struct RoleProtectedMiddleware: AsyncMiddleware {
    let allowedRoles: [UserRole]
    
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let user = try request.auth.require(User.self)
        guard allowedRoles.contains(user.role) else {
            throw Abort(.forbidden, reason: "Unauthorized access. Please contact the developer")
        }
        
        return try await next.respond(to: request)
    }
}
