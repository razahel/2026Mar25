import SwiftUI

struct RepositoryWebScreen: View {
  private let viewModel: RepositoryWebViewModel
  
  init(dependency: RepositoryWebDependency, url: URL) {
    let component = RepositoryWebComponent(dependency: dependency)
    self.viewModel = RepositoryWebViewModel(component: component, url: url)
  }
  
  var body: some View {
    RepositoryWebView(viewModel: viewModel)
      .ignoresSafeArea(edges: .bottom)
  }
}
