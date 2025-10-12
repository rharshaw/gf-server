//
//  CreateRegistrationToken.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Vapor
import Fluent

struct CreateRegistrationToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("registration_tokens")
            .id()
            .field("value", .string, .required)
            .field("expires_at", .datetime)
            .unique(on: "value")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("registration_tokens").delete()
    }
}

struct AddAddressCodeToRegistrationToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("registration_tokens")
            .field("address_code_id", .uuid, .references("address_codes", "id"))
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("registration_tokens")
            .deleteField("address_code_id")
            .update()
    }
}
