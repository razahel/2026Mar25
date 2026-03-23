import SwiftUI
import SwiftData

struct SearchScreen: View {
  @Environment(\.modelContext) private var modelContext
  private let githubService: GithubServiceProtocol
  
  init(githubService: GithubServiceProtocol) {
    self.githubService = githubService
  }
  
  var body: some View {
    SearchScreenContainer(
      githubService: githubService,
      recentSearchRepository: SwiftDataRecentSearchRepository(modelContext: modelContext)
    )
  }
}

private struct SearchScreenContainer: View {
  @StateObject private var viewModel: SearchViewModel
  
  init(githubService: GithubServiceProtocol, recentSearchRepository: RecentSearchRepositoryProtocol) {
    _viewModel = StateObject(
      wrappedValue: SearchViewModel(
        githubService: githubService,
        recentSearchRepository: recentSearchRepository
      )
    )
  }
  
  var body: some View {
    NavigationStack {
      SearchView(viewModel: viewModel)
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
