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
  
  init(component: RepositoryWebComponent, url: URL) {
    self.url = url
  }
}
