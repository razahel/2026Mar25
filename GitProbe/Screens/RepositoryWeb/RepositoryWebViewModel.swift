import Foundation
import Combine

@MainActor
final class RepositoryWebViewModel: ObservableObject {
  let url: URL
  
  init(component: RepositoryWebComponent, url: URL) {
    self.url = url
  }
}
