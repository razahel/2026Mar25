import Foundation

protocol HTTPClient {
  func get(url: URL) async throws -> (Data, HTTPURLResponse)
}

struct URLSessionHTTPClient: HTTPClient {
  let session: URLSession
  
  func get(url: URL) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await session.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw HTTPClientError.invalidResponse
    }
    return (data, httpResponse)
  }
}

enum HTTPClientError: Error {
  case invalidResponse
}
