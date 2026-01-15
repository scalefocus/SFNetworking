//
//  ApiRequest+Extension.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 16.05.23.
//

import Foundation

extension ApiRequest {
    
    public var requiresAuthorization: Bool { false }

    public var headers: [String: String] { [:] }

    /// Executes an API call.
    ///
    /// - Parameters:
    ///    - networkClient: the network client to use. It could be real or mock.
    ///    - environment: determines whether to use live or mock environment.
    ///
    /// - Returns: the backend response encoded by using the infered request response type.
    /// - Throws: An ApiError exception containing all the information from the server.
    ///
    public func request(
        networkClient: NetworkClientProtocol,
        environment: ApiEnvironment
    ) async throws -> NetworkResult<ResponseType> {
        
        if let response = try await response(for: environment, networkClient: networkClient) {
            return response
        }

        switch environment {
        case .failing:
            throw NetworkError.invalidData
        case .throwing(let error):
            throw error
        case .mock:
            throw NetworkError.invalidResponse
        default:
            break
        }

        let encoder = JSONEncoder()
        let jsonData: Data? = method == .get ? nil : try encoder.encode(self)
        let result = try await networkClient.request(
            endpoint: "/" + endpoint,
            method: method,
            headers: headers,
            body: jsonData,
            expecting: ResponseType.self,
            authorized: requiresAuthorization,
            refreshTokenIfNecessary: true
        )

        return result
    }

    func response(
        for environment: ApiEnvironment,
        networkClient: NetworkClientProtocol
    ) async throws -> NetworkResult<ResponseType>? {
        return nil
    }
}
