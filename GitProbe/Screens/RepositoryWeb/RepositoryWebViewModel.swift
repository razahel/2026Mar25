//
//  RepositoryWebViewModel.swift
//  GitProbe
//
//  Created by Yoon Kang on 24/3/26.
//

import Foundation
import Combine

@MainActor
final class RepositoryWebViewModel: ObservableObject {
  @Published var url: URL
  @Published var loadingProgress: Double = 0
  let repository: RepositorySearchItem
  
  init(component: RepositoryWebComponent, url: URL, repository: RepositorySearchItem) {
    self.url = url
    self.repository = repository
  }
}
