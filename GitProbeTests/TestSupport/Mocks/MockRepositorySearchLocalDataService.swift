//
//  MockRepositorySearchLocalDataService.swift
//  GitProbeTests
//

import Foundation
@testable import GitProbe

final class MockRepositorySearchLocalDataService: RepositorySearchLocalDataService, @unchecked Sendable {
  private let lock = NSLock()
  private var items: [RecentSearchItem] = []
  private var fetchError: Error?
  private var saveError: Error?
  private var deleteError: Error?
  private var deleteAllError: Error?

  init(
    initialItems: [RecentSearchItem] = [],
    fetchError: Error? = nil,
    saveError: Error? = nil,
    deleteError: Error? = nil,
    deleteAllError: Error? = nil
  ) {
    self.items = initialItems
    self.fetchError = fetchError
    self.saveError = saveError
    self.deleteError = deleteError
    self.deleteAllError = deleteAllError
  }

  func fetchRecentSearches() throws -> [RecentSearchItem] {
    try lock.withLock {
      if let fetchError { throw fetchError }
      return items.sorted(by: { $0.searchedAt > $1.searchedAt })
    }
  }

  func save(keyword: String) throws {
    try lock.withLock {
      if let saveError { throw saveError }
      let normalized = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
      guard normalized.isEmpty == false else { return }

      let now = Date()
      if let index = items.firstIndex(where: { $0.keyword.caseInsensitiveCompare(normalized) == .orderedSame }) {
        items[index] = RecentSearchItem(keyword: normalized, searchedAt: now)
      } else {
        items.append(RecentSearchItem(keyword: normalized, searchedAt: now))
      }

      items.sort(by: { $0.searchedAt > $1.searchedAt })
      if items.count > 10 {
        items = Array(items.prefix(10))
      }
    }
  }

  func delete(keyword: String) throws {
    try lock.withLock {
      if let deleteError { throw deleteError }
      items.removeAll { $0.keyword == keyword }
    }
  }

  func deleteAll() throws {
    try lock.withLock {
      if let deleteAllError { throw deleteAllError }
      items.removeAll()
    }
  }

  func snapshotItems() -> [RecentSearchItem] {
    lock.withLock { items }
  }
}
