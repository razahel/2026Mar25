//
//  LocalDataClient.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import SwiftData

protocol LocalDataClient {
  func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T]
  func insert<T: PersistentModel>(_ model: T)
  func delete<T: PersistentModel>(_ model: T)
  func save() throws
}

@MainActor
final class SwiftDataLocalDataClient: LocalDataClient {
  private let modelContext: ModelContext
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
    try modelContext.fetch(descriptor)
  }
  
  func insert<T: PersistentModel>(_ model: T) {
    modelContext.insert(model)
  }
  
  func delete<T: PersistentModel>(_ model: T) {
    modelContext.delete(model)
  }
  
  func save() throws {
    try modelContext.save()
  }
}
