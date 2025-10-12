//
//  AddressCode.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Foundation
import Fluent

final class AddressCode: Model, @unchecked Sendable {
    static let schema = "address_codes"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "code")
    var code: String
    
    @Field(key: "address")
    var address: String
    
    @Field(key: "is_valid")
    var isValid: Bool
    
    init() { }

    init(id: UUID? = nil, code: String, address: String, isValid: Bool) {
        self.id = id
        self.code = code
        self.address = address
        self.isValid = isValid
    }
    
  
    func toResponseDTO() -> AddressCodeResponseDTO {
        .init(
            code: self.code,
            address: self.address,
            
        )
    }
}
