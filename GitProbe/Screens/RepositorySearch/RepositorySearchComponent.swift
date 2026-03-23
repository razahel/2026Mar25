import Foundation

protocol RepositorySearchDependency {
  var httpClient: HTTPClient { get }
  var localDataClient: SwiftDataLocalDataClient { get }
}

struct RepositorySearchComponent: RepositoryWebDependency {
  let apiService: RepositorySearchAPIService
  let localDataService: RepositorySearchLocalDataService

  init(dependency: RepositorySearchDependency) {
    self.apiService = RepositorySearchAPIServiceImpl(httpClient: dependency.httpClient)
    self.localDataService = RepositorySearchLocalDataServiceImpl(localDataClient: dependency.localDataClient)
  }
}
