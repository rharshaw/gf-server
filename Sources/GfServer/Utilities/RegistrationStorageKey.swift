//
//  RegistrationStorageKey.swift
//  GfServer
//
//  Created by Rian Harshaw on 10/11/25.
//

import Vapor
import Fluent
import Foundation

struct RegistrationTokenStorageKey: StorageKey {
    typealias Value = RegistrationToken
}
