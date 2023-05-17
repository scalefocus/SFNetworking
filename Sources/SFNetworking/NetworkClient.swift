//
//  NetworkClient.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 16.05.23.
//

import Foundation

public class NetworkClient: NetworkClientProtocol {

    public var baseUrl: String
    public var isLoggingEnabled: Bool

    private weak var urlSession: URLSession?
    private var authHandler: NetworkAuthHandler?

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter
    }()

    public init(
        baseUrl: String,
        urlSession: URLSession = URLSession.shared,
        isLoggingEnabled: Bool = false,
        authHandler: NetworkAuthHandler? = nil
    ) {
        self.baseUrl = baseUrl
        self.urlSession = urlSession
        self.isLoggingEnabled = isLoggingEnabled
        self.authHandler = authHandler
    }

    public func request<T: Decodable>(
        endpoint: String,
        method: HttpMethod = .get,
        headers: HttpHeaders = [:],
        body: Data? = nil,
        expecting type: T.Type = String.self,
        authorized: Bool = false,
        refreshTokenIfNecessary: Bool = true
    ) async throws -> NetworkResult<T> {

        guard let urlSession = self.urlSession else {
            throw NetworkError.invalidSession
        }

        guard let url = URL(string: baseUrl + endpoint) else {
            throw NetworkError.invalidURL
        }

        // build request
        let requestHeaders = processHeaders(headers, authorized: authorized)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for (key, value) in requestHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body

        if isLoggingEnabled {
            log(NetworkClient.dateFormatter.string(from: Date()))
            log(getCurlString(request))
        }

        // do request
        let (data, response) = try await urlSession.data(for: request)

        // process response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if isLoggingEnabled {
            log("HttpStatus: \(httpResponse.statusCode)")
            log(prettyPrint(data))
        }

        guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
            throw NetworkError.fail(data, httpResponse)
        }

        if httpResponse.statusCode == 401 && authorized {
            if refreshTokenIfNecessary && authHandler != nil {
                try await authHandler?.refreshToken()
                return try await self.request(
                    endpoint: endpoint,
                    method: method,
                    headers: headers,
                    body: data,
                    expecting: type,
                    authorized: authorized,
                    refreshTokenIfNecessary: false
                )
            }
            else {
                throw NetworkError.failedToRefreshToken
            }
        }

        if type == String.self {
            let text = data.count == 0 ? "" : String(decoding: data, as: UTF8.self)
            return NetworkResult(statusCode: httpResponse.statusCode, data: text as! T)
        }

        let decoder = JSONDecoder()
        let object = try decoder.decode(type, from: data)
        return NetworkResult(statusCode: httpResponse.statusCode, data: object)
    }

    func processHeaders(_ headers: HttpHeaders, authorized: Bool) -> HttpHeaders {
        var requestHeaders = [
            "Content-Type": "application/json; charset=utf-8",
        ]
        for (key, value) in headers {
            requestHeaders[key] = value
        }
        if authorized {
            if let authHandler = self.authHandler {
                let (authKey, authValue) = authHandler.getAuthHeader()
                requestHeaders[authKey] = authValue
            }
        }
        return requestHeaders
    }

    func log(_ message: String) {
        print(message)
    }

    func getCurlString(_ request: URLRequest) -> String {
        guard let url = request.url else { return "" }

        var baseCommand = "curl \"\(url.absoluteString)\""

        if request.httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = request.httpMethod, method != "GET", method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H \"\(key): \(value)\"")
            }
        }

        if let data = request.httpBody, var body = String(data: data, encoding: .utf8) {
            body = body.replacingOccurrences(of: "\"", with: "\\\"")
            command.append("-d \"\(body)\"")
        }

        return command.joined(separator: " \\\n\t")
    }

    func prettyPrint(_ data: Data?) -> String {
        guard let data = data else { return "" }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted]
            )
            let prettyPrintedString = NSString(
                data: data,
                encoding: String.Encoding.utf8.rawValue
            )
            return prettyPrintedString as? String ?? ""
        } catch {
            return ""
        }
    }
}

