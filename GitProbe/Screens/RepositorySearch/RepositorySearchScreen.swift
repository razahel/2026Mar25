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
      let localDataClient = SwiftDataLocalDataClient(modelContext: modelContext)
      let localDataService = RepositorySearchLocalDataServiceImpl(localDataClient: localDataClient)
      let viewModel = RepositorySearchViewModel(
        repositorySearchService: repositorySearchService,
        localDataService: localDataService
      )
      RepositorySearchView(viewModel: viewModel)
    }
  }
}
