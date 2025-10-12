//
//  TokenDTO.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Vapor


struct TokenResponseDTO: Content {
    let token: String
    let expiresAt: Date?
}
