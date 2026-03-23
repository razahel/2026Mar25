import Foundation
import SwiftData

@Model
final class RecentSearchSchema {
  var keyword: String
  var searchedAt: Date
  
  init(keyword: String, searchedAt: Date) {
    self.keyword = keyword
    self.searchedAt = searchedAt
  }
}
