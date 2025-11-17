//
//  User.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Foundation
import Vapor
import Fluent

enum UserRole: String, Codable {
    case user, admin, developer
}


final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "address")
    var address: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "hoa_board")
    var hoaBoard: Bool
    
    @Field(key: "hoa_position")
    var hoaPosition: String?
    
    @Field(key: "profile_photo_url")
    var profilePhotoURL: String
    
    @Enum(key: "role")
    var role: UserRole
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String, address: String, email: String, passwordHash: String, hoaBoard: Bool, hoaPosition: String?, profilePhotoURL: String, role: UserRole) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.email = email
        self.passwordHash = passwordHash
        self.hoaBoard = hoaBoard
        self.hoaPosition = hoaPosition
        self.profilePhotoURL = profilePhotoURL
        self.role = role
    }
    
    func toDTO() -> UserResponseDTO {
        .init(
            id: self.id!,
            profilePhotoURL: self.profilePhotoURL,
            firstName: self.firstName,
            lastName: self.lastName,
            address: self.address,
            hoaBoard: self.hoaBoard,
            hoaPosition: self.hoaPosition,
            role: self.role
        )
    }
}
