import Foundation

struct AppContainer {
  let httpClient: HTTPClient
  
  init() {
    let session = URLSession(configuration: .default)
    let client = URLSessionHTTPClient(session: session)
    self.httpClient = client
  }
}
