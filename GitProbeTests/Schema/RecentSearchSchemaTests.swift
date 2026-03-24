//
//  RecentSearchSchemaTests.swift
//  GitProbeTests
//

import Foundation
import Testing
@testable import GitProbe

struct RecentSearchSchemaTests {
  @Test
  func initSetsStoredProperties() {
    let date = Date(timeIntervalSince1970: 1_700_000_111)
    let model = RecentSearchSchema(keyword: "swift", searchedAt: date)

    #expect(model.keyword == "swift")
    #expect(model.searchedAt == date)
  }
}
