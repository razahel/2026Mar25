//
//  MockHTTPClient.swift
//  GitProbeTests
//

import Foundation
@testable import GitProbe

struct MockHTTPClient: HTTPClient {
  var handler: (URL) async throws -> (Data, HTTPURLResponse)

  init(handler: @escaping (URL) async throws -> (Data, HTTPURLResponse)) {
    self.handler = handler
  }

  init(result: Result<(Data, HTTPURLResponse), Error>) {
    self.handler = { _ in
      try result.get()
    }
  }

  func get(url: URL) async throws -> (Data, HTTPURLResponse) {
    try await handler(url)
  }
}
