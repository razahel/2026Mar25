import Foundation

struct AppContainer {
  let httpClient: HTTPClient
  let searchService: RepositorySearchService
  
  init() {
    let session = URLSession(configuration: .default)
    let client = URLSessionHTTPClient(session: session)
    self.httpClient = client
    self.searchService = RepositorySearchServiceImpl(httpClient: client)
  }
}
