//
//  File.swift
//  
//
//  Created by tsvetan.raykov on 17.05.23.
//

import Foundation

public protocol NetworkAuthHandler {
    func getAuthHeader() -> (String, String)
    func refreshToken() async throws
}
