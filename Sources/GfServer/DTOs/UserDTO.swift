//
//  UserDTO.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Foundation
import Vapor

struct UserResponseDTO: Content {
    var profilePhotoURL: String
    var firstName: String
    var lastName: String
    var address: String
    var hoaBoard: Bool
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

struct UserRequestDTO: Content {
    let firstName: String
    let lastName: String
    let address: String
    let email: String
    let password: String
    let profilePhotoURL: String
}
