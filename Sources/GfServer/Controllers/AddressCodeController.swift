//
//  AddressCodeController.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Fluent
import Vapor

struct AddressCodeController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let addressCodes = routes.grouped("api", "address-codes")
        let protected = addressCodes.grouped(RegistrationTokenMiddleware())
        let tokenProtected = addressCodes.grouped(UserToken.authenticator(), User.guardMiddleware())
        let adminProtected = tokenProtected.grouped(RoleProtectedMiddleware(allowedRoles: [.developer, .admin]))
        let developerProtected = tokenProtected.grouped(RoleProtectedMiddleware(allowedRoles: [.developer]))
        
        addressCodes.get("validate", ":code", use: validate)
        tokenProtected.post("invalidate", ":code", use: invalidate)
        adminProtected.get("index", use: index)
        addressCodes.post("create", use: create)
    }
    
    @Sendable func index(req: Request) async throws -> [AddressCodeResponseDTO] {
        try await AddressCode.query(on: req.db).all().filter { $0.isValid }.map { $0.toResponseDTO() }
    }
    
    @Sendable func create(req: Request) async throws -> AddressCodeResponseDTO {
        var generatedCode: String
        
        repeat {
            generatedCode = generateCode()
            
            let exists = try await AddressCode.query(on: req.db)
                .filter(\.$code == generatedCode)
                .first() != nil
            
            if !exists {
                break
            }
        } while true
        
        let data = try req.content.decode(AddressCodeRequestDTO.self)
        
        let newAddress = AddressCode(code: generatedCode, address: data.address, isValid: true)
        
        try await newAddress.save(on: req.db)
        
        return newAddress.toResponseDTO()
    }
    
    @Sendable func validate(req: Request) async throws -> AddressCodeTokenResponseDTO {
        // Check if code is entered. If not, then abort.
        guard let code = req.parameters.get("code") else {
            throw ServerError(.badRequest, reason: "Missing code")
        }
        
        // Check code against the database to see if it's present.
        guard let addressCode = try await AddressCode.query(on: req.db)
            .filter(\.$code == code)
            .first()
        else {
            throw ServerError(.badRequest, reason: "Address not found with that code")
        }
        
        // Address is present. Now to make sure that the address is available for use by the isValid boolean.
        guard addressCode.isValid else {
            throw ServerError(.badRequest, reason: "Address code has been used.")
        }
        
        let tokenValue = [UInt8].random(count: 32).base64
        let expiration = Date().addingTimeInterval(60 * 5)
        let token = RegistrationToken(value: tokenValue, expiresAt: expiration)
        token.$addressCode.id = addressCode.id
        
        try await token.save(on: req.db)
        
        
        // All is good. Return the DTO.
        return AddressCodeTokenResponseDTO(address: addressCode.address, token: tokenValue, expiresAt: expiration)
    }
    
    @Sendable func invalidate(req: Request) async throws -> AddressCodeResponseDTO {
        guard let code = req.parameters.get("code") else {
            throw ServerError(.badRequest, reason: "Missing code")
        }
        
        guard let addressCode = try await AddressCode.query(on: req.db)
            .filter(\.$code == code)
            .first()
        else {
            throw ServerError(.badRequest, reason: "Address not found with that code")
        }
        
        addressCode.isValid = false
        try await addressCode.save(on: req.db)

        return addressCode.toResponseDTO()
    }
    
    func generateCode(length: Int = 10) -> String {
        let characters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = ""
        
        for _ in 0..<length {
            if let random = characters.randomElement() {
                result.append(random)
            }
        }
        return result
    }
    
}
