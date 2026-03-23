import Foundation

protocol RepositorySearchDependency {
  var httpClient: HTTPClient { get }
}

struct RepositorySearchComponent {
  let httpClient: HTTPClient
  
  init(dependency: RepositorySearchDependency) {
    self.httpClient = dependency.httpClient
  }
  
  func makeAPIService() -> RepositorySearchAPIService {
    RepositorySearchAPIServiceImpl(httpClient: httpClient)
  }
}
