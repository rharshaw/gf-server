//
//  .swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Vapor
import Fluent

struct CreateUsers: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let userRole = try await database.enum("user_role").read()

        try await database.schema("users")
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("address", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("hoa_board", .bool, .required)
            .field("profile_photo_url", .string, .required)
            .field("role", userRole, .required)
            .unique(on: "email")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
