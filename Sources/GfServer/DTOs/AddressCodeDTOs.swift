//
//  AddressCodeDTO.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Foundation
import Vapor


struct AddressCodeRequestDTO: Content {
    let address: String
}

struct AddressCodeResponseDTO: Content {
    let code: String
    let address: String
}

struct AddressCodeTokenResponseDTO: Content {
    let address: String
    let token: String
    let expiresAt: Date
}
