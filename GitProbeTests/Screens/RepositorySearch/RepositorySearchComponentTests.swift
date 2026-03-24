//
//  RepositorySearchComponentTests.swift
//  GitProbeTests
//

import Foundation
import SwiftData
import Testing
@testable import GitProbe

struct RepositorySearchComponentTests {
  @Test
  @MainActor
  func injectableInitializerFeedsViewModel() {
    let api = MockRepositorySearchAPIService(response: .init(totalCount: 0, items: []))
    let local = MockRepositorySearchLocalDataService()
    let component = RepositorySearchComponent(apiService: api, localDataService: local)
    let vm = RepositorySearchViewModel(component: component)

    vm.onAppear()
    #expect(vm.recentSearches.isEmpty)
  }
}

private func dummyHTTPResponse(urlString: String) -> HTTPURLResponse {
  HTTPURLResponse(url: URL(string: urlString)!, statusCode: 200, httpVersion: nil, headerFields: nil)!
}

@MainActor
private func makeSwiftDataClientForTests() throws -> SwiftDataLocalDataClient {
  let schema = Schema([RecentSearchSchema.self])
  let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
  let container = try ModelContainer(for: schema, configurations: [configuration])
  return SwiftDataLocalDataClient(modelContext: container.mainContext)
}

private struct TestRepositorySearchDependency: RepositorySearchDependency {
  let httpClient: HTTPClient
  let localDataClient: SwiftDataLocalDataClient
}
