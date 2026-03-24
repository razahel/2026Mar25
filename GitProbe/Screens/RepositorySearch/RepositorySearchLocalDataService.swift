//
//  RepositorySearchLocalDataService.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import Foundation
import SwiftData

protocol RepositorySearchLocalDataService {
  func fetchRecentSearches() throws -> [RecentSearchItem]
  func save(keyword: String) throws
  func delete(keyword: String) throws
  func deleteAll() throws
}

struct RecentSearchItem: Identifiable, Hashable {
  var id: String { keyword }
  let keyword: String
  let searchedAt: Date
}

@MainActor
final class RepositorySearchLocalDataServiceImpl: RepositorySearchLocalDataService {
  private let localDataClient: LocalDataClient
  private let maxCount = 10
  
  init(localDataClient: LocalDataClient) {
    self.localDataClient = localDataClient
  }
  
  func fetchRecentSearches() throws -> [RecentSearchItem] {
    let descriptor = FetchDescriptor<RecentSearchSchema>(
      sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
    )
    let entities = try localDataClient.fetch(descriptor)
    return entities.map { RecentSearchItem(keyword: $0.keyword, searchedAt: $0.searchedAt) }
  }
  
  func save(keyword: String) throws {
    let normalized = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalized.isEmpty == false else { return }
    
    let all = try localDataClient.fetch(FetchDescriptor<RecentSearchSchema>())
    if let existing = all.first(where: { $0.keyword.caseInsensitiveCompare(normalized) == .orderedSame }) {
      existing.searchedAt = Date()
      existing.keyword = normalized
    } else {
      localDataClient.insert(RecentSearchSchema(keyword: normalized, searchedAt: Date()))
    }
    
    let sorted = try localDataClient.fetch(
      FetchDescriptor<RecentSearchSchema>(sortBy: [SortDescriptor(\.searchedAt, order: .reverse)])
    )
    if sorted.count > maxCount {
      for overflow in sorted[maxCount...] {
        localDataClient.delete(overflow)
      }
    }
    
    try localDataClient.save()
  }
  
  func delete(keyword: String) throws {
    let all = try localDataClient.fetch(FetchDescriptor<RecentSearchSchema>())
    for entity in all where entity.keyword == keyword {
      localDataClient.delete(entity)
    }
    try localDataClient.save()
  }
  
  func deleteAll() throws {
    let all = try localDataClient.fetch(FetchDescriptor<RecentSearchSchema>())
    for entity in all {
      localDataClient.delete(entity)
    }
    try localDataClient.save()
  }
}
