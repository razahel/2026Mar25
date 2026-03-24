//
//  InMemorySwiftDataStack.swift
//  GitProbeTests
//

import SwiftData
@testable import GitProbe

enum InMemorySwiftDataStack {
  @MainActor
  static func makeLocalDataService() throws -> RepositorySearchLocalDataService {
    let schema = Schema([RecentSearchSchema.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let client = SwiftDataLocalDataClient(modelContext: container.mainContext)
    return RepositorySearchLocalDataServiceImpl(localDataClient: client)
  }
}
