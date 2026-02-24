//
//  HttpMethod.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 16.05.23.
//

import Foundation

public enum HttpMethod: String, Encodable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
}
