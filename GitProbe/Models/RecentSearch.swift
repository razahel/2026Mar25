import Foundation
import SwiftData

@Model
final class RecentSearch {
  var keyword: String
  var searchedAt: Date
  
  init(keyword: String, searchedAt: Date) {
    self.keyword = keyword
    self.searchedAt = searchedAt
  }
}

struct RecentSearchItem: Identifiable, Hashable {
  var id: String { keyword }
  let keyword: String
  let searchedAt: Date
}
