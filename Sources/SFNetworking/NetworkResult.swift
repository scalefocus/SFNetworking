//
//  NetworkResult.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 16.05.23.
//

import Foundation

public struct NetworkResult<T> {
    public let statusCode: Int
    public let data: T

    public init(statusCode: Int, data: T) {
        self.statusCode = statusCode
        self.data = data
    }
}
