//
//  CreateAddressCode.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Fluent

struct CreateAddressCode: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("address_codes")
            .id()
            .field("code", .string, .required)
            .field("address", .string, .required)
            .field("is_valid", .bool, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("address_codes").delete()
    }
}

