import SwiftUI

struct RepositoryWebScreen: View {
  @StateObject private var viewModel: RepositoryWebViewModel
  
  init(repositoryURL: URL) {
    _viewModel = StateObject(wrappedValue: RepositoryWebViewModel(repositoryURL: repositoryURL))
  }
  
  var body: some View {
    RepositoryWebView(viewModel: viewModel)
      .ignoresSafeArea(edges: .bottom)
  }
}
