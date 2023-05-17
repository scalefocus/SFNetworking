//
//  NetworkClientMock.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 17.05.23.
//

import Foundation

class NetworkClientMock: NetworkClientProtocol {

    var baseUrl: String = ""

    func request<T>(
        endpoint: String,
        method: HttpMethod,
        headers: HttpHeaders,
        body: Data?,
        expecting type: T.Type,
        authorized: Bool,
        refreshTokenIfNecessary: Bool
    ) async throws -> NetworkResult<T> where T : Decodable {
        throw NetworkError.invalidResponse
    }
}
