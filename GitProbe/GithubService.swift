import Foundation

protocol GithubServiceProtocol {
  func searchRepositories(keyword: String, page: Int) async throws -> GithubSearchResponse
}

struct GithubService: GithubServiceProtocol {
  private let httpClient: HTTPClient
  
  init(httpClient: HTTPClient) {
    self.httpClient = httpClient
  }
  
  func searchRepositories(keyword: String, page: Int) async throws -> GithubSearchResponse {
    guard var components = URLComponents(string: "https://api.github.com/search/repositories") else {
      throw GithubServiceError.invalidURL
    }
    
    components.queryItems = [
      URLQueryItem(name: "q", value: keyword),
      URLQueryItem(name: "page", value: "\(page)")
    ]
    
    guard let url = components.url else {
      throw GithubServiceError.invalidURL
    }
    
    let (data, response) = try await httpClient.get(url: url)
    guard (200...299).contains(response.statusCode) else {
      throw GithubServiceError.badStatusCode(response.statusCode)
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(GithubSearchResponse.self, from: data)
    } catch {
      throw GithubServiceError.decodingFailed
    }
  }
}

enum GithubServiceError: Error {
  case invalidURL
  case badStatusCode(Int)
  case decodingFailed
}
