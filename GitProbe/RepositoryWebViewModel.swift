import Foundation

@MainActor
final class RepositoryWebViewModel: ObservableObject {
  let repositoryURL: URL
  
  init(repositoryURL: URL) {
    self.repositoryURL = repositoryURL
  }
}
