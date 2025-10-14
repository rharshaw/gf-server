//
//  File.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        let passwordProtected = users.grouped(User.authenticator())
        let tokenProtected = users.grouped(UserToken.authenticator())
        
        
        users.post("create", use: create)
        passwordProtected.post("login", use: login)
        tokenProtected.get("currentuser", use: getCurrentUser)
    }
    
    
    @Sendable func getCurrentUser(req: Request) async throws -> User {
        try req.auth.require(User.self)
    }
    
    @Sendable func login(req: Request) async throws -> UserTokenResponseDTO {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return UserTokenResponseDTO(token: token.value, user: user.toDTO())
    }
    
    @Sendable func create(req: Request) async throws -> UserRegistrationResponseDTO {
        try User.Create.validate(content: req)
        let dto = try req.content.decode(UserRegistrationDTO.self)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let user = try User(firstName: dto.firstName, lastName: dto.lastName, address: dto.address, email: create.username, passwordHash: Bcrypt.hash(create.password), hoaBoard: false, profilePhotoURL: dto.profilePhotoURL, role: .user)
        
        try await user.save(on: req.db)
        
        let token = try user.generateToken()
        
        try await token.save(on: req.db)
        
        return UserRegistrationResponseDTO(token: token.value, response: user.toDTO())
    }
}
