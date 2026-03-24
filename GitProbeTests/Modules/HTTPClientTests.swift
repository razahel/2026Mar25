//
//  HTTPClientTests.swift
//  GitProbeTests
//

import Foundation
import Testing
@testable import GitProbe

struct HTTPClientTests {
  @Test
  func urlSessionHTTPClientThrowsWhenResponseIsNotHTTP() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [NonHTTPResponseURLProtocol.self]
    let session = URLSession(configuration: configuration)
    let client = URLSessionHTTPClient(session: session)
    let url = URL(string: "https://example.com/api")!

    await #expect(throws: HTTPClientError.invalidResponse) {
      _ = try await client.get(url: url)
    }
  }
}

private final class NonHTTPResponseURLProtocol: URLProtocol {
  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    client?.urlProtocol(self, didReceive: URLResponse(), cacheStoragePolicy: .notAllowed)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
