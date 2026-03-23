import SwiftUI
import SwiftData

struct RepositorySearchScreen: View {
  @Environment(\.modelContext) private var modelContext
  private let httpClient: HTTPClient
  
  init(httpClient: HTTPClient) {
    self.httpClient = httpClient
  }
  
  var body: some View {
    NavigationStack {
      let apiService = RepositorySearchAPIServiceImpl(httpClient: httpClient)
      let localDataClient = SwiftDataLocalDataClient(modelContext: modelContext)
      let localDataService = RepositorySearchLocalDataServiceImpl(localDataClient: localDataClient)
      let viewModel = RepositorySearchViewModel(
        repositorySearchAPIService: apiService,
        localDataService: localDataService
      )
      RepositorySearchView(viewModel: viewModel)
    }
  }
}
