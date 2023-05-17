//
//  NetworkError.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 16.05.23.
//

import Foundation

public enum NetworkError: Error {

    /**
     * The UrlSession is invalid.
     */
    case invalidSession

    /**
     * The request URL is invalid.
     */
    case invalidURL

    /**
     *  The returned response is not a HTTP response.
     */
    case invalidResponse

    /**
     *  The HTTP request failed with a non-200 status code.
     */
    case fail(Data, HTTPURLResponse)

    /**
     *  The expected data could not be decoded.
     */
    case invalidData

    /**
     *  Other networking errors.
     */
    case other(Error)

    /**
     *  Failed to refresh the authorization token.
     */
    case failedToRefreshToken
}
