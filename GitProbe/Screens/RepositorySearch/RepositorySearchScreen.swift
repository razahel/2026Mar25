//
//  RepositorySearchScreen.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import SwiftUI
import SwiftData

struct RepositorySearchScreen: View {
  private let viewModel: RepositorySearchViewModel
  
  init(dependency: RepositorySearchDependency) {
    let component = RepositorySearchComponent(dependency: dependency)    
    self.viewModel = RepositorySearchViewModel(component: component)
  }
  
  var body: some View {
    RepositorySearchView(viewModel: viewModel)
  }
}
