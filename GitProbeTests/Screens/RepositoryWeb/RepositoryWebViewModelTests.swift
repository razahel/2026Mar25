//
//  RepositoryWebViewModelTests.swift
//  GitProbeTests
//

import Foundation
import Testing
@testable import GitProbe

@MainActor
struct RepositoryWebViewModelTests {
  @Test
  func initStoresURLAndRepository() {
    let repo = RepositorySearchItem(
      id: 99,
      name: "demo",
      owner: GitOwner(login: "u", avatarURL: URL(string: "https://example.com/a.png")!),
      htmlURL: URL(string: "https://github.com/u/demo")!
    )
    let webURL = URL(string: "https://github.com/u/demo/wiki")!
    let vm = RepositoryWebViewModel(
      component: RepositoryWebComponent(dependency: TestWebDependency()),
      url: webURL,
      repository: repo
    )

    #expect(vm.url == webURL)
    #expect(vm.repository.id == 99)
    #expect(vm.repository.name == "demo")
    #expect(vm.loadingProgress == 0)
  }
}

private struct TestWebDependency: RepositoryWebDependency {}
