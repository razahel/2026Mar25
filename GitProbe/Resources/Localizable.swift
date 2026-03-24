import Foundation

enum Localizable {
  case searchTitle
  case searchPlaceholder
  case recentTitle
  case recentDeleteAll
  case commonErrorTitle
  case commonConfirm
  case errorRecentDelete
  case errorRecentDeleteAll
  case errorRecentFetch
  case errorRecentSave
  case errorSearch
  case searchResultCountFormat
  
  var string: String {
    switch self {
    case .searchTitle:
      String(localized: "search.title")
    case .searchPlaceholder:
      String(localized: "search.placeholder")
    case .recentTitle:
      String(localized: "recent.title")
    case .recentDeleteAll:
      String(localized: "recent.delete_all")
    case .commonErrorTitle:
      String(localized: "common.error.title")
    case .commonConfirm:
      String(localized: "common.confirm")
    case .errorRecentDelete:
      String(localized: "error.recent.delete")
    case .errorRecentDeleteAll:
      String(localized: "error.recent.delete_all")
    case .errorRecentFetch:
      String(localized: "error.recent.fetch")
    case .errorRecentSave:
      String(localized: "error.recent.save")
    case .errorSearch:
      String(localized: "error.search")
    case .searchResultCountFormat:
      String(localized: "search.result.count.format")
    }
  }
}
