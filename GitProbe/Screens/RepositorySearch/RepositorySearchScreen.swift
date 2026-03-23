import SwiftUI
import SwiftData

struct RepositorySearchScreen: View {
  @Environment(\.modelContext) private var modelContext
  private let component: RepositorySearchComponent
  
  init(component: RepositorySearchComponent) {
    self.component = component
  }
  
  var body: some View {
    NavigationStack {
      let apiService = component.makeAPIService()
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
