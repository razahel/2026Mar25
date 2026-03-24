//
//  RepositorySearchViewModelTests.swift
//  GitProbeTests
//

import Foundation
import Testing
@testable import GitProbe

@MainActor
struct RepositorySearchViewModelTests {
  @Test
  func onAppearRefreshesRecentSearches() {
    let local = MockRepositorySearchLocalDataService(
      initialItems: [RecentSearchItem(keyword: "k", searchedAt: Date())]
    )
    let api = MockRepositorySearchAPIService(response: .empty)
    let vm = RepositorySearchViewModel(
      component: RepositorySearchComponent(apiService: api, localDataService: local)
    )

    vm.onAppear()

    #expect(vm.recentSearches.map(\.keyword) == ["k"])
    #expect(vm.state == .viewingRecentSearched)
  }

  @Test
  func nonEmptyQuerySetsEditingTextAndClearsRepositoriesWhenWasLoaded() async {
    let local = MockRepositorySearchLocalDataService()
    let api = MockRepositorySearchAPIService(response: .empty)
    let vm = RepositorySearchViewModel(
      component: RepositorySearchComponent(apiService: api, localDataService: local)
    )

    vm.query = "q"
    for _ in 0 ..< 50 {
      await Task.yield()
      if vm.state == .editingText { break }
    }

    #expect(vm.state == .editingText)
    #expect(vm.repositories.isEmpty)
  }

  @Test
  func onTapSearchLoadsRepositories() async throws {
    let item = RepositorySearchItem.sample(id: 1, name: "r1")
    let local = MockRepositorySearchLocalDataService()
    let api = MockRepositorySearchAPIService(
      response: RepositorySearchResponse(totalCount: 1, items: [item])
    )
    let vm = RepositorySearchViewModel(
      component: RepositorySearchComponent(apiService: api, localDataService: local)
    )

    vm.query = "swift"
    vm.onTapSearch()

    try await waitUntil { vm.state == .loaded && vm.repositories.count == 1 }

    #expect(vm.totalCount == 1)
    #expect(vm.repositories[0].name == "r1")
    #expect(vm.errorMessage == nil)
    #expect(local.snapshotItems().map(\.keyword).contains("swift"))
  }

  @Test
  func searchFailureSetsErrorMessage() async throws {
    let local = MockRepositorySearchLocalDataService()
    let api = MockRepositorySearchAPIService(error: URLError(.badServerResponse))
    let vm = RepositorySearchViewModel(
      component: RepositorySearchComponent(apiService: api, localDataService: local)
    )

    vm.query = "x"
    vm.onTapSearch()

    try await waitUntil { vm.state == .loaded && vm.errorMessage != nil }

    #expect(vm.repositories.isEmpty)
    #expect(vm.errorMessage == Localizable.errorSearch.string)
  }

  @Test
  func onTapDeleteRecentSearchPropagatesFailure() {
    struct TestError: Error {}
    let local = MockRepositorySearchLocalDataService(deleteError: TestError())
    let api = MockRepositorySearchAPIService(response: .empty)
    let vm = RepositorySearchViewModel(
      component: RepositorySearchComponent(apiService: api, localDataService: local)
    )

    vm.onTapDeleteRecentSearch(keyword: "k")

    #expect(vm.errorMessage == Localizable.errorRecentDelete.string)
  }
}

private extension RepositorySearchResponse {
  static var empty: RepositorySearchResponse {
    RepositorySearchResponse(totalCount: 0, items: [])
  }
}

private extension RepositorySearchItem {
  static func sample(id: Int, name: String) -> RepositorySearchItem {
    RepositorySearchItem(
      id: id,
      name: name,
      owner: GitOwner(login: "owner", avatarURL: URL(string: "https://example.com/a.png")!),
      htmlURL: URL(string: "https://github.com/owner/\(name)")!
    )
  }
}

private enum WaitUntilError: Error {
  case timedOut
}

private func waitUntil(
  timeout: Duration = .seconds(2),
  _ condition: @escaping @MainActor () -> Bool
) async throws {
  let deadline = ContinuousClock.now + timeout
  while ContinuousClock.now < deadline {
    if await MainActor.run(body: condition) {
      return
    }
    try await Task.sleep(for: .milliseconds(5))
  }
  throw WaitUntilError.timedOut
}

