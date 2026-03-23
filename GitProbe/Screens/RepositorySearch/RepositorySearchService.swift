import Foundation

protocol RepositorySearchService {
  func searchRepositories(keyword: String, page: Int) async throws -> RepositorySearchResponse
}

struct RepositorySearchServiceImpl: RepositorySearchService {
  private let httpClient: HTTPClient
  
  init(httpClient: HTTPClient) {
    self.httpClient = httpClient
  }
  
  func searchRepositories(keyword: String, page: Int) async throws -> RepositorySearchResponse {
    guard var components = URLComponents(string: "https://api.github.com/search/repositories") else {
      throw RepositorySearchServiceError.invalidURL
    }
    
    components.queryItems = [
      URLQueryItem(name: "q", value: keyword),
      URLQueryItem(name: "page", value: "\(page)")
    ]
    
    guard let url = components.url else {
      throw RepositorySearchServiceError.invalidURL
    }
    
    let (data, response) = try await httpClient.get(url: url)
    guard (200...299).contains(response.statusCode) else {
      throw RepositorySearchServiceError.badStatusCode(response.statusCode)
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(RepositorySearchResponse.self, from: data)
    } catch {
      throw RepositorySearchServiceError.decodingFailed
    }
  }
}

enum RepositorySearchServiceError: Error {
  case invalidURL
  case badStatusCode(Int)
  case decodingFailed
}

struct RepositorySearchResponse: Decodable {
  let totalCount: Int
  let items: [RepositorySearchItem]
  
  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case items
  }
}

struct RepositorySearchItem: Decodable, Identifiable, Hashable {
  let id: Int
  let name: String
  let owner: GitOwner
  let htmlURL: URL
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case owner
    case htmlURL = "html_url"
  }
}

struct GitOwner: Decodable, Hashable {
  let login: String
  let avatarURL: URL
  
  enum CodingKeys: String, CodingKey {
    case login
    case avatarURL = "avatar_url"
  }
}
