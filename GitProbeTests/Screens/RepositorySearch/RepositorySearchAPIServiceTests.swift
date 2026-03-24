//
//  RepositorySearchAPIServiceTests.swift
//  GitProbeTests
//

import Foundation
import Testing
@testable import GitProbe

struct RepositorySearchAPIServiceTests {
  @Test
  func searchRepositoriesDecodesSuccessPayload() async throws {
    let json = """
    {
      "total_count": 1,
      "items": [
        {
          "id": 42,
          "name": "repo",
          "owner": { "login": "user", "avatar_url": "https://example.com/a.png" },
          "html_url": "https://github.com/user/repo"
        }
      ]
    }
    """.data(using: .utf8)!
    let url = URL(string: "https://api.github.com/search/repositories?q=test&page=1")!
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let http = MockHTTPClient(result: .success((json, response)))
    let service = RepositorySearchAPIServiceImpl(httpClient: http)

    let result = try await service.searchRepositories(keyword: "test", page: 1)

    #expect(result.totalCount == 1)
    #expect(result.items.count == 1)
    #expect(result.items[0].id == 42)
    #expect(result.items[0].name == "repo")
    #expect(result.items[0].owner.login == "user")
    #expect(result.items[0].htmlURL.absoluteString == "https://github.com/user/repo")
  }

  @Test
  func searchRepositoriesThrowsOnNon2xxStatus() async throws {
    let url = URL(string: "https://api.github.com/search/repositories?q=x&page=1")!
    let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
    let http = MockHTTPClient(result: .success((Data(), response)))
    let service = RepositorySearchAPIServiceImpl(httpClient: http)

    await #expect(throws: RepositorySearchServiceError.badStatusCode(500)) {
      _ = try await service.searchRepositories(keyword: "x", page: 1)
    }
  }

  @Test
  func searchRepositoriesThrowsOnInvalidJSON() async throws {
    let data = Data("{".utf8)
    let url = URL(string: "https://api.github.com/search/repositories?q=x&page=1")!
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let http = MockHTTPClient(result: .success((data, response)))
    let service = RepositorySearchAPIServiceImpl(httpClient: http)

    await #expect(throws: RepositorySearchServiceError.decodingFailed) {
      _ = try await service.searchRepositories(keyword: "x", page: 1)
    }
  }
}
