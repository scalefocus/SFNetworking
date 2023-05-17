//
//  ApiEnvironment.swift
//  SfNetworking
//
//  Created by tsvetan.raykov on 16.05.23.
//

import Foundation

/// Defines the environment in which a backend API call executes
///
public enum ApiEnvironment {

    /// A live environment. A real network call will be made by uding the provided network client
    case live

    /// A mock environment. Usually no network call is made and a static response is returned.
    case mock

    /// Throws the default exception.
    case failing

    /// Throws specific xxception.
    case throwing(Error)
}
