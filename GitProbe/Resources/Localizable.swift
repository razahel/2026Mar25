import Foundation
import SwiftUI

enum Localizable: String {
  case searchTitle = "search.title"
  case searchPlaceholder = "search.placeholder"
  case recentTitle = "recent.title"
  case recentDeleteAll = "recent.delete_all"
  case commonErrorTitle = "common.error.title"
  case commonConfirm = "common.confirm"
  case errorRecentDelete = "error.recent.delete"
  case errorRecentDeleteAll = "error.recent.delete_all"
  case errorRecentFetch = "error.recent.fetch"
  case errorRecentSave = "error.recent.save"
  case errorSearch = "error.search"
  case searchResultCountFormat = "search.result.count.format"
  
  var text: LocalizedStringKey {
    LocalizedStringKey(rawValue)
  }
  
  var string: String {
    NSLocalizedString(rawValue, comment: "")
  }
}
