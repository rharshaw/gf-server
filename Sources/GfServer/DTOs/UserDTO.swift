//
//  UserDTO.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Foundation
import Vapor

struct UserResponseDTO: Content {
    var id: UUID
    var profilePhotoObjectKey: String
    var profilePhotoURL: String
    var firstName: String
    var lastName: String
    var address: String
    var hoaBoard: Bool
    var hoaPosition: String?
    var role: UserRole
    
    func toModel() -> User {
        let model = User()
                model.firstName = self.firstName
        model.lastName = self.lastName
        model.address = self.address
        model.hoaBoard = self.hoaBoard
        model.profilePhotoURL = self.profilePhotoURL
        model.role = self.role
        return model
    }
}
struct UserRegistrationDTO: Content {
    var username: String
    var password: String
    var confirmPassword: String
    var firstName: String
    var lastName: String
    var address: String
    var hoaBoard: Bool?
    var hoaPosition: String?
    var role: UserRole?
    var profilePhotoURL: String
}

struct UserRegistrationRequestDTO: Content {
    var id: UUID? = nil 
    var profilePhoto: Data
    var username: String
    var password: String
    var confirmPassword: String
    var firstName: String
    var lastName: String
    var address: String
    var hoaBoard: Bool?
    var hoaPosition: String?
    var role: UserRole?
}

struct UserRegistrationResponseDTO: Content {
    let token: String
    let response: UserResponseDTO
}

struct UserRequestDTO: Content {
    let firstName: String
    let lastName: String
    let address: String
    let email: String
    let password: String
    let profilePhotoURL: String
}

struct UserTokenResponseDTO: Content {
    let token: String
    let user: UserResponseDTO
}

struct UserProfileUpdateRequestDTO: Content {
    let firstName: String?
    let lastName: String?
    let profilePhotoURL: String?
    let email: String?
    let password: String?
}


struct UserUpdateStatusRequestDTO: Content {
    let hoaBoard: Bool?
    let hoaPosition: String?
    let role: UserRole?
}

