//
//  RepositoryWebScreen.swift
//  GitProbe
//
//  Created by Yoon Kang on 24/3/26.
//

import SwiftUI

struct RepositoryWebScreen: View {
  private let viewModel: RepositoryWebViewModel
  
  init(dependency: RepositoryWebDependency, url: URL, repository: RepositorySearchItem) {
    let component = RepositoryWebComponent(dependency: dependency)
    self.viewModel = RepositoryWebViewModel(component: component, url: url, repository: repository)
  }
  
  var body: some View {
    RepositoryWebView(viewModel: viewModel)
  }
}
