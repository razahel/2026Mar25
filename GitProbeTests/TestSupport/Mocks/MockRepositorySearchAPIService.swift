//
//  MockRepositorySearchAPIService.swift
//  GitProbeTests
//

import Foundation
@testable import GitProbe

actor MockRepositorySearchAPIService: RepositorySearchAPIService {
  private var handler: @Sendable (String, Int) async throws -> RepositorySearchResponse

  init(handler: @escaping @Sendable (String, Int) async throws -> RepositorySearchResponse) {
    self.handler = handler
  }

  init(response: RepositorySearchResponse) {
    self.handler = { _, _ in response }
  }

  init(error: Error) {
    self.handler = { _, _ in throw error }
  }

  func setHandler(_ newHandler: @escaping @Sendable (String, Int) async throws -> RepositorySearchResponse) {
    handler = newHandler
  }

  func searchRepositories(keyword: String, page: Int) async throws -> RepositorySearchResponse {
    try await handler(keyword, page)
  }
}
