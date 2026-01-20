//
//  NetworkClientProtocol.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 17.05.23.
//

import Foundation

public typealias HttpHeaders = [String: String]

public protocol NetworkClientProtocol {

    var baseUrl: String { get set }

    /**
     * Handles HTTP requests for specific endpoint.
     *
     *  - Parameters:
     *      - endpoint: the relative address for the endpoing.
     *      - the HTTP method that should be used (e.g. GET, POST, PUT, etc.)
     *      - headers: a list of key-value pairs representing each HTTP header to be passed.
     *      - body: the method payload
     *      - type: the expected `Decodable` type to be returned from the request.
     *      - authorized: determines whether header bearer authorisation should be used.
     *      - refreshTokenIfNecessary: if the request fails with error 401, it will call the refreshToken method.
     *
     *  - Returns:
     *      A `NetworkResult` that contains the `statusCode` and the expected response type in the `data` property.
     */
    func request<T: Decodable>(
        endpoint: String,
        method: HttpMethod,
        headers: HttpHeaders,
        body: Data?,
        expecting type: T.Type,
        authorized: Bool,
        timeoutInterval: TimeInterval,
        refreshTokenIfNecessary: Bool
    ) async throws -> NetworkResult<T>
}
