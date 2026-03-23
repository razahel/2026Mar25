import Foundation

struct AppContainer {
  let httpClient: HTTPClient
  let githubService: GithubServiceProtocol
  
  init() {
    let session = URLSession(configuration: .default)
    let client = URLSessionHTTPClient(session: session)
    self.httpClient = client
    self.githubService = GithubService(httpClient: client)
  }
}
