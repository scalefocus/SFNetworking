//
//  ApiRequest.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 16.05.23.
//

import Foundation

/// Describes how the HTTP request body should be constructed.
public enum RequestBody {
    /// Encode the request struct as JSON (default behaviour for non-GET/HEAD methods).
    case json
    /// Send raw bytes as the body (e.g. binary chunk uploads).
    case raw(Data)
    /// Send no body regardless of HTTP method.
    case none
}

/// A base protocol fort all API requests
///
public protocol ApiRequest: Encodable {

    /// Defines the response type. It is infered when implementing the response:for: method
    associatedtype ResponseType: Decodable

    /// The API server path. The full path is constructed by concatenating the existing baseUrl from network client environment.
    var endpoint: String { get }

    /// The HTTP method to use.
    var method: HttpMethod { get }

    /// A dictionary containing all request headers
    var headers: [String: String] { get }

    /// Indicates whether this request requires an authenticated user.
    var requiresAuthorization: Bool { get }

    /// Optional multipart payload for the request.
    var multipartData: MultipartData? { get }

    /// The timeout interval, in seconds, for the request.
    var timeoutInterval: TimeInterval { get }

    /// Defines how the request body is constructed.
    var requestBody: RequestBody { get }

    /// This method is called before processing any request. If it returns a non-nil result, the processing stops and the call returns the value obtained by this method
    ///
    /// - Parameters:
    ///     - environment: Determines whether to use live or mock environment.
    ///     - networkClient: The network client.
    ///
    /// - Returns: The server response
    /// - Throws: An ApiError containing all backend error information coming from the server.
    ///
    func response(
        for environment: ApiEnvironment,
        networkClient: NetworkClientProtocol
    ) async throws -> NetworkResult<ResponseType>?
}
