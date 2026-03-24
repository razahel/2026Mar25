//
//  RepositorySearchViewModel.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import Combine
import Foundation

@MainActor
final class RepositorySearchViewModel: ObservableObject {
  @Published var query: String = ""
  @Published private(set) var repositories: [RepositorySearchItem] = []
  @Published private(set) var totalCount: Int = 0
  @Published private(set) var isInitialLoading: Bool = false
  @Published private(set) var isNextPageLoading: Bool = false
  @Published private(set) var recentSearches: [RecentSearchItem] = []
  @Published private(set) var autocompleteItems: [RecentSearchItem] = []
  @Published var errorMessage: String?
  
  var showRecentSearches: Bool {
    query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  
  var showAutocomplete: Bool {
    showRecentSearches == false && autocompleteItems.isEmpty == false
  }
  
  var repositorWebDependency: RepositoryWebDependency {
    return component
  }
  
  private let component: RepositorySearchComponent
  private let apiService: RepositorySearchAPIService
  private let localDataService: RepositorySearchLocalDataService
  private var currentPage: Int = 1
  private var hasMore: Bool = true
  private var cancellables = Set<AnyCancellable>()
  
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
    Task { await search(with: query) }
  }
  
  func onTapRecentSearch(_ item: RecentSearchItem) {
    query = item.keyword
    Task { await search(with: item.keyword) }
  }
  
  func onTapAutocomplete(_ item: RecentSearchItem) {
    query = item.keyword
    Task { await search(with: item.keyword) }
  }
  
  func onAppearRepositoryItem(_ item: RepositorySearchItem) {
    guard hasMore, isInitialLoading == false, isNextPageLoading == false else { return }
    guard let index = repositories.firstIndex(where: { $0.id == item.id }) else { return }
    
    let triggerIndex = repositories.count / 2
    guard index >= triggerIndex else { return }
    
    Task { await fetchPage(page: currentPage + 1, reset: false) }
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
      .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
      .removeDuplicates()
      .sink { [weak self] keyword in
        guard let self else { return }
        
        if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          self.autocompleteItems = []
          return
        }
        
        self.autocompleteItems = self.recentSearches
          .filter { $0.keyword.localizedCaseInsensitiveContains(keyword) }
          .sorted(by: { $0.searchedAt > $1.searchedAt })
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
    guard trimmed.isEmpty == false else { return }
    
    do {
      try localDataService.save(keyword: trimmed)
      refreshRecentSearches()
    } catch {
      errorMessage = Localizable.errorRecentSave.string
    }
    
    await fetchPage(page: 1, reset: true)
  }
  
  private func fetchPage(page: Int, reset: Bool) async {
    if reset {
      isInitialLoading = true
      errorMessage = nil
      repositories = []
      currentPage = 1
      hasMore = true
    } else {
      isNextPageLoading = true
    }
    
    defer {
      if reset {
        isInitialLoading = false
      } else {
        isNextPageLoading = false
      }
    }
    
    do {
      let response = try await apiService.searchRepositories(keyword: query, page: page)
      totalCount = response.totalCount
      currentPage = page
      
      if reset {
        repositories = response.items
      } else {
        repositories.append(contentsOf: response.items)
      }
      hasMore = repositories.count < totalCount
    } catch {
      errorMessage = Localizable.errorSearch.string
    }
  }
  
  var localizedResultCountText: String {
    let format = Localizable.searchResultCountFormat.string
    return String(format: format, locale: Locale.current, totalCount)
  }
  
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM. dd."
    return formatter
  }()
}
