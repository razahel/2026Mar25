import Foundation

struct GithubSearchResponse: Decodable {
  let totalCount: Int
  let items: [GitRepository]
  
  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case items
  }
}

struct GitRepository: Decodable, Identifiable, Hashable {
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
