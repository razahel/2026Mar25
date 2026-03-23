import SwiftUI
import SwiftData

struct SearchScreen: View {
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
        .alert("오류", isPresented: Binding(
          get: { viewModel.errorMessage != nil },
          set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
          Button("확인", role: .cancel) { }
        } message: {
          Text(viewModel.errorMessage ?? "")
        }
    }
  }
}
