import Foundation
import SwiftData

protocol RecentSearchRepositoryProtocol {
  func fetchRecentSearches() throws -> [RecentSearchItem]
  func save(keyword: String) throws
  func delete(keyword: String) throws
  func deleteAll() throws
}

@MainActor
final class SwiftDataRecentSearchRepository: RecentSearchRepositoryProtocol {
  private let modelContext: ModelContext
  private let maxCount = 10
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  func fetchRecentSearches() throws -> [RecentSearchItem] {
    let descriptor = FetchDescriptor<RecentSearch>(
      sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
    )
    let entities = try modelContext.fetch(descriptor)
    return entities.map { RecentSearchItem(keyword: $0.keyword, searchedAt: $0.searchedAt) }
  }
  
  func save(keyword: String) throws {
    let normalized = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else { return }
    
    let all = try modelContext.fetch(FetchDescriptor<RecentSearch>())
    if let existing = all.first(where: { $0.keyword.caseInsensitiveCompare(normalized) == .orderedSame }) {
      existing.searchedAt = Date()
      existing.keyword = normalized
    } else {
      modelContext.insert(RecentSearch(keyword: normalized, searchedAt: Date()))
    }
    
    let sorted = try modelContext.fetch(
      FetchDescriptor<RecentSearch>(sortBy: [SortDescriptor(\.searchedAt, order: .reverse)])
    )
    if sorted.count > maxCount {
      for overflow in sorted[maxCount...] {
        modelContext.delete(overflow)
      }
    }
    
    try modelContext.save()
  }
  
  func delete(keyword: String) throws {
    let all = try modelContext.fetch(FetchDescriptor<RecentSearch>())
    for entity in all where entity.keyword == keyword {
      modelContext.delete(entity)
    }
    try modelContext.save()
  }
  
  func deleteAll() throws {
    let all = try modelContext.fetch(FetchDescriptor<RecentSearch>())
    for entity in all {
      modelContext.delete(entity)
    }
    try modelContext.save()
  }
}
