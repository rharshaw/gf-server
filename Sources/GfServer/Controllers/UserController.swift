//
//  File.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Vapor
import Fluent
import SotoS3

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        let passwordProtected = users.grouped(User.authenticator())
        let tokenProtected = users.grouped(UserToken.authenticator())
        let developerRoute = tokenProtected.grouped(RoleProtectedMiddleware(allowedRoles: [.developer]))
        
        users.post("create", use: create)
        users.delete("delete", ":id", use: delete)
        passwordProtected.post("login", use: login)
        tokenProtected.get("currentuser", use: getCurrentUser)
        tokenProtected.get("index", use: index)
        tokenProtected.put("update", ":id", use: update)
        developerRoute.put("updateUser", ":id", use: updateUser)
        
        
    }
    
    @Sendable func updateUser(req: Request) async throws -> UserResponseDTO {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let dto = try req.content.decode(UserUpdateStatusRequestDTO.self)
        
        if let hoaBoard = dto.hoaBoard {
            user.hoaBoard = hoaBoard
        }
        
        if let hoaPosition = dto.hoaPosition {
            user.hoaPosition = hoaPosition
        }
        
        if let role = dto.role {
            user.role = role
        }
        
        try await user.update(on: req.db)
        return user.toDTO()
    }
    
    @Sendable func update(req: Request) async throws -> UserResponseDTO {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
      
        let dto = try req.content.decode(UserProfileUpdateRequestDTO.self)
        
        if let firstName = dto.firstName {
            user.firstName = firstName
        }
        
        if let lastName = dto.lastName {
            user.lastName = lastName
        }
        
        if let profilePhotoURL = dto.profilePhotoURL {
            user.profilePhotoURL = profilePhotoURL
        }
        
        if let email = dto.email {
            user.email = email
        }
        
        if let password = dto.password {
            user.passwordHash = try Bcrypt.hash(password)
        }
        
        
        try await user.update(on: req.db)
        
        return user.toDTO()
    }
    
    
    @Sendable func delete(req: Request) async throws -> UserResponseDTO {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await UserToken.query(on: req.db)
            .filter (\.$user.$id == user.id!)
            .delete()
        
        try await user.delete(on: req.db)
        return user.toDTO()
    }
    
    @Sendable func index(req: Request) async throws -> [UserResponseDTO] {
        let allUsers = try await User.query(on: req.db).all().map { $0.toDTO() }
        let randomTenUsers = allUsers.shuffled().prefix(10)
        
        return Array(randomTenUsers)
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
        var dto = try req.content.decode(UserRegistrationRequestDTO.self)
        dto.id = dto.id ?? UUID()
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let service = S3Service(req: req)
        
        let (objectKey, urlString) = try await service.uploadProfilePhoto(data: dto.profilePhoto, key: dto.id!.uuidString, contentType: "image/jpeg")
        
        let user = try User(id: dto.id, firstName: dto.firstName, lastName: dto.lastName, address: dto.address, email: create.username, passwordHash: Bcrypt.hash(create.password), hoaBoard: dto.hoaBoard ?? false, hoaPosition: dto.hoaPosition ?? nil, profilePhotoURL: urlString, profilePhotoObjectKey: objectKey, role: dto.role ?? .user)
        
        try await user.save(on: req.db)
        
        let token = try user.generateToken()
        
        try await token.save(on: req.db)
        
        return UserRegistrationResponseDTO(token: token.value, response: user.toDTO())
    }
}

