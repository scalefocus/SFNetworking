# SFNetworking

This package is used to handle REST method calls.

## Usage:

An API request can be defined by implementing the `ApiRequest` protocol.

```swift
public protocol ApiRequest: Encodable {

    /// The API server path. The full path is constructed by concatenating the 
    /// existing baseUrl from network client environment.
    var endpoint: String { get }

    /// The HTTP method to use.
    var method: HttpMethod { get }

    /// A dictionary containing all request headers
    var headers: [String: String] { get }

    /// Determines whether default bearer authorisation should be used. 
    var requiresAuthorization: Bool { get }

    /// This method is called before processing any request. 
    /// If it returns a non-nil result, the processing stops and the call returns 
    /// the value obtained by this method
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
```

An example implementation looks like this:

```swift
struct MyRequest: ApiRequest {

    var endpoint: String { "api/users" }

    var method: HttpMethod { .post }

    var headers: [String : String] { [:] }

    // Payload parameters
    var name: String

    var job: String
    
    // Default response
    func response(
        for environment: ApiEnvironment, 
        networkClient: NetworkClientProtocol
    ) async throws -> NetworkResult<User>? {

        switch environment {
        case .mock:
            return MyResponse.mock
        default:
            return nil
        }
    }
}
```

This endpoint can be executed by using a `NetworkClientProtocol` instance calling the request method of the API:

```swift
let client = NetworkClient(baseUrl: "https://reqres.in")
//...
Task {
    do {
        let rq = MyRequest(name: "Petar", job: "Ivanov")
        let response = try await rq.request(networkClient: client, environment: .live)
        //...
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

- `NetworkClient` provides a default implementation of the `NetworkClientProtocol`
- `NetworkClientMock` is mock implementation that can be used for testing.

A failing API request can be simulated by just changing the `environment` argument.

```swift
let response = try await rq.request(networkClient: client, environment: .failing)
``` 
