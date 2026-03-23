import SwiftUI
import SwiftData

struct RepositorySearchScreen: View {
  @Environment(\.modelContext) private var modelContext
  private let repositorySearchService: RepositorySearchService
  
  init(repositorySearchService: RepositorySearchService) {
    self.repositorySearchService = repositorySearchService
  }
  
  var body: some View {
    RepositorySearchScreenContainer(
      repositorySearchService: repositorySearchService,
      recentSearchRepository: SwiftDataRecentSearchRepository(modelContext: modelContext)
    )
  }
}

private struct RepositorySearchScreenContainer: View {
  @StateObject private var viewModel: RepositorySearchViewModel
  
  init(repositorySearchService: RepositorySearchService, recentSearchRepository: RecentSearchRepositoryProtocol) {
    _viewModel = StateObject(
      wrappedValue: RepositorySearchViewModel(
        repositorySearchService: repositorySearchService,
        recentSearchRepository: recentSearchRepository
      )
    )
  }
  
  var body: some View {
    NavigationStack {
      RepositorySearchView(viewModel: viewModel)
        .onAppear {
          viewModel.onAppear()
        }
        .alert(L10N.commonErrorTitle.text, isPresented: Binding(
          get: { viewModel.errorMessage != nil },
          set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
          Button(L10N.commonConfirm.text, role: .cancel) { }
        } message: {
          Text(viewModel.errorMessage ?? "")
        }
    }
  }
}
