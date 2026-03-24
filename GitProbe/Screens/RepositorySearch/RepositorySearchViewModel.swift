//
//  RepositorySearchViewModel.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import Combine
import Foundation

enum RepositorySearchState {
  case viewingRecentSearched
  case editingText
  case loadingFirstPage
  case loaded
}

@MainActor
final class RepositorySearchViewModel: ObservableObject {
  @Published var state: RepositorySearchState = .viewingRecentSearched
  @Published var query: String = ""
  @Published private(set) var repositories: [RepositorySearchItem] = []
  @Published private(set) var totalCount = 0
  @Published private(set) var recentSearches: [RecentSearchItem] = []
  @Published private(set) var autocompleteItems: [RecentSearchItem] = []
  @Published var isLoadingNextPage = false
  @Published var errorMessage: String?
    
  var repositorWebDependency: RepositoryWebDependency {
    return component
  }
  
  private let component: RepositorySearchComponent
  private let apiService: RepositorySearchAPIService
  private let localDataService: RepositorySearchLocalDataService
  private var currentPage = 1
  private var hasMore = true
  private var cancellables = Set<AnyCancellable>()
  
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM. dd."
    return formatter
  }()

  init(component: RepositorySearchComponent) {
    self.component = component
    self.apiService = component.apiService
    self.localDataService = component.localDataService
    
    bindQuery()
  }
  
  func onAppear() {
    refreshRecentSearches()
  }
  
  func onTapSearch() {
    Task {
      await search(with: query)
    }
  }
  
  func onTapRecentSearch(_ item: RecentSearchItem) {
    query = item.keyword
    Task {
      await search(with: item.keyword)
    }
  }
  
  func onTapAutocomplete(_ item: RecentSearchItem) {
    query = item.keyword
    Task {
      await search(with: item.keyword)
    }
  }
  
  func onAppearRepositoryItem(_ item: RepositorySearchItem) {
    guard hasMore, state == .loaded else {
      return
    }
    
    guard let index = repositories.firstIndex(where: { $0.id == item.id }) else {
      return
    }
    
    let triggerIndex = repositories.count / 2
    guard index >= triggerIndex else {
      return
    }
    
    Task {
      await fetchPage(page: currentPage + 1)
    }
  }
  
  func onTapDeleteRecentSearch(keyword: String) {
    do {
      try localDataService.delete(keyword: keyword)
      refreshRecentSearches()
    } catch {
      errorMessage = Localizable.errorRecentDelete.string
    }
  }
  
  func onTapDeleteAllRecentSearches() {
    do {
      try localDataService.deleteAll()
      refreshRecentSearches()
    } catch {
      errorMessage = Localizable.errorRecentDeleteAll.string
    }
  }
  
  func formattedDate(_ date: Date) -> String {
    Self.dateFormatter.string(from: date)
  }
  
  private func bindQuery() {
    $query
      .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
      .removeDuplicates()
      .sink { [weak self] keyword in
        guard let self else {
          return
        }
        
        switch self.state {
        case .loaded, .viewingRecentSearched, .editingText:
          if keyword.count > 0 {
            self.state = .editingText
            self.repositories.removeAll()
          } else {
            self.state = .viewingRecentSearched
          }
        case .loadingFirstPage:
          break
        }
        
        if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          self.autocompleteItems = []
        } else {
          self.autocompleteItems = self.recentSearches
            .filter { $0.keyword.localizedCaseInsensitiveContains(keyword) }
            .sorted(by: { $0.searchedAt > $1.searchedAt })
        }
      }
      .store(in: &cancellables)
  }
  
  private func refreshRecentSearches() {
    do {
      recentSearches = try localDataService.fetchRecentSearches()
      // 최근 검색어가 변경되면 자동완성도 즉시 반영합니다.
      let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
      autocompleteItems = keyword.isEmpty
        ? []
        : recentSearches.filter { $0.keyword.localizedCaseInsensitiveContains(keyword) }
    } catch {
      errorMessage = Localizable.errorRecentFetch.string
    }
  }
  
  private func search(with keyword: String) async {
    let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty == false else {
      return
    }
    
    do {
      try localDataService.save(keyword: trimmed)
      refreshRecentSearches()
    } catch {
      errorMessage = Localizable.errorRecentSave.string
    }
    
    await fetchPage(page: 1)
  }
  
  private func fetchPage(page: Int) async {
    let isLoadingMore = page > 1
    if isLoadingMore {
      if isLoadingNextPage {
        return
      }
      
      isLoadingNextPage = true
    } else {
      if state == .loadingFirstPage {
        return
      }
      
      state = .loadingFirstPage
      errorMessage = nil
      repositories = []
      currentPage = 1
      hasMore = true
    }
    
    defer {
      state = .loaded
      isLoadingNextPage = false
    }
    
    do {
      let response = try await apiService.searchRepositories(keyword: query, page: page)
      totalCount = response.totalCount
      currentPage = page
      
      if isLoadingMore {
        repositories.append(contentsOf: response.items)
      } else {
        repositories = response.items
      }
      
      hasMore = repositories.count < totalCount
    } catch {
      errorMessage = Localizable.errorSearch.string
    }
  }
}
