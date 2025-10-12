//
//  File.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Foundation
import Fluent

struct CreateUserRoleEnum: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        let _ = try await database.enum("user_role")
            .case("user")
            .case("admin")
            .case("developer")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.enum("user_role").delete()
    }
}
