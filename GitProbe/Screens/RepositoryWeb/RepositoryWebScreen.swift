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
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          HStack(spacing: 8) {
            AsyncImage(url: viewModel.repository.owner.avatarURL) { phase in
              switch phase {
              case .success(let image):
                image.resizable().scaledToFill()
              default:
                Color(.systemGray5)
              }
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            
            Text(viewModel.repository.name)
              .font(.headline)
              .lineLimit(1)
          }
        }
      }
  }
}
