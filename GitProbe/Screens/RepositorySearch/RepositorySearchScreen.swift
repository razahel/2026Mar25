import SwiftUI
import SwiftData

struct RepositorySearchScreen: View {
  @Environment(\.modelContext) private var modelContext
  private let repositorySearchService: RepositorySearchService
  
  init(repositorySearchService: RepositorySearchService) {
    self.repositorySearchService = repositorySearchService
  }
  
  var body: some View {
    NavigationStack {
      let viewModel = RepositorySearchViewModel(
        repositorySearchService: repositorySearchService,
        recentSearchRepository: SwiftDataRecentSearchRepository(modelContext: modelContext)
      )
      RepositorySearchView(viewModel: viewModel)
    }
  }
}
