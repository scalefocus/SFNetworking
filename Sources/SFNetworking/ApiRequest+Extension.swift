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

    public var multipartData: MultipartData? { nil }

    public var timeoutInterval: TimeInterval { 60 }

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

        var headers = self.headers
        var body: Data?
        if let multipartData {
            let boundary = "Boundary-\(UUID().uuidString)"
            body = getMultipartBody(multipartData: multipartData, boundary: boundary)
            headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        } else {
            let encoder = JSONEncoder()
            body = method == .get ? nil : try encoder.encode(self)
        }
        let result = try await networkClient.request(
            endpoint: "/" + endpoint,
            method: method,
            headers: headers,
            body: body,
            expecting: ResponseType.self,
            authorized: requiresAuthorization,
            timeoutInterval: timeoutInterval,
            refreshTokenIfNecessary: true
        )

        return result
    }

    private func getMultipartBody(multipartData: MultipartData, boundary: String) -> Data {
        var body = Data()

        for (key, data) in multipartData.fields {
            body.append(multipartField(named: key, value: data, boundary: boundary))
        }

        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(multipartData.fieldName)\"; filename=\"\(multipartData.fileName)\"\r\n".utf8))
        body.append(Data("Content-Type: \(multipartData.contentType)\r\n".utf8))
        body.append(Data("Content-Length: \(multipartData.data.count)\r\n\r\n".utf8))
        body.append(multipartData.data)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))

        return body
    }

    private func multipartField(named name: String, value: String, boundary: String) -> Data {
        var data = Data()
        data.append(Data("--\(boundary)\r\n".utf8))
        data.append(Data("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8))
        data.append(Data("\(value)\r\n".utf8))
        return data
    }

    public func response(
        for environment: ApiEnvironment,
        networkClient: NetworkClientProtocol
    ) async throws -> NetworkResult<ResponseType>? {
        return nil
    }
}
