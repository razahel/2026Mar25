//
//  RepositorySearchView.swift
//  GitProbe
//
//  Created by Yoon Kang on 23/3/26.
//

import SwiftUI

struct RepositorySearchView: View {
  @ObservedObject var viewModel: RepositorySearchViewModel
  @FocusState private var isSearchFieldFocused: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      titleView
      searchInputView
      contentView
    }
    .padding(.horizontal, 16)
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.onAppear()
    }
    .alert(Localizable.commonErrorTitle.string, isPresented: Binding(
      get: { 
        viewModel.errorMessage != nil
      },
      set: {
        if $0 == false {
          viewModel.errorMessage = nil
        }
      }
    )) {
      Button(Localizable.commonConfirm.string, role: .cancel) {
      }
    } message: {
      Text(viewModel.errorMessage ?? "")
    }
  }

  private var titleView: some View {
    HStack(spacing: 8) {
      Text(Localizable.searchTitle.string)
        .font(.largeTitle)
        .bold()
      Spacer()
      if viewModel.isLoadingNextPage {
        ProgressView()
      }
    }
    .padding(.top, 8)
  }
  
  private var searchInputView: some View {
    HStack(spacing: 8) {
      Image(systemName: Assets.magnifyingglass.name)
        .foregroundStyle(.secondary)
      TextField(Localizable.searchPlaceholder.string, text: $viewModel.query)
        .focused($isSearchFieldFocused)
        .submitLabel(.search)
        .onSubmit {
          isSearchFieldFocused = false
          viewModel.onTapSearch()
        }
      
      if viewModel.query.isEmpty == false {
        Button {
          viewModel.query = ""
        } label: {
          Image(systemName: Assets.xmarkCircleFill.name)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 8)
    .background(Color(.secondarySystemFill))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
  
  @ViewBuilder
  private var contentView: some View {
    switch viewModel.state {
    case .viewingRecentSearched:
      recentSearchView
    case .editingText:
      autocompleteView
    case .loadingFirstPage:
      Spacer()
      HStack {
        Spacer()
        ProgressView()
        Spacer()
      }
      Spacer()
    case .loaded:
      resultView
    }
  }
  
  private var recentSearchView: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(Localizable.recentTitle.string)
          .font(.headline)
        Spacer()
        if viewModel.recentSearches.isEmpty == false {
          Button(Localizable.recentDeleteAll.string) {
            viewModel.onTapDeleteAllRecentSearches()
          }
          .font(.caption)
          .foregroundStyle(.pink)
        }
      }
      
      ForEach(viewModel.recentSearches) { item in
        HStack {
          Button(item.keyword) {
            isSearchFieldFocused = false
            viewModel.onTapRecentSearch(item)
          }
          .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
          .contentShape(Rectangle())
          .buttonStyle(.plain)
          .foregroundStyle(.primary)
          
          Button {
            viewModel.onTapDeleteRecentSearch(keyword: item.keyword)
          } label: {
            Image(systemName: Assets.xmark.name)
              .foregroundStyle(.secondary)
          }
          .frame(width: 44, height: 44)
          .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .font(.subheadline)
      }
      
      Spacer()
    }
  }
  
  private var autocompleteView: some View {
    List {
      ForEach(viewModel.autocompleteItems) { item in
        Button {
          isSearchFieldFocused = false
          viewModel.onTapAutocomplete(item)
        } label: {
          HStack {
            Text(item.keyword)
              .foregroundStyle(.primary)
            Spacer()
            Text(DateFormatter.monthDate.string(from: item.searchedAt))
              .foregroundStyle(.secondary)
              .font(.caption)
          }
        }
        .buttonStyle(.plain)
      }
    }
    .listStyle(.plain)
  }
  
  private var resultView: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(String(format: Localizable.searchResultCountFormat.string, locale: Locale.current, viewModel.totalCount))
        .font(.caption)
        .foregroundStyle(.secondary)
      
      List {
        ForEach(viewModel.repositories) { item in
          NavigationLink {
            RepositoryWebScreen(
              dependency: viewModel.repositorWebDependency,
              url: item.htmlURL,
              repository: item
            )
          } label: {
            RepositoryRowView(item: item)
          }
          .onAppear {
            viewModel.onAppearRepositoryItem(item)
          }
        }
      }
      .listStyle(.plain)
    }
  }
}

private struct RepositoryRowView: View {
  let item: RepositorySearchItem
  
  var body: some View {
    HStack(spacing: 10) {
      AsyncImage(url: item.owner.avatarURL) { phase in
        switch phase {
        case .success(let image):
          image.resizable().scaledToFill()
        default:
          Color(.systemGray5)
        }
      }
      .frame(width: 36, height: 36)
      .clipShape(Circle())
      
      VStack(alignment: .leading, spacing: 2) {
        Text(item.name)
          .font(.headline)
          .foregroundStyle(.primary)
        Text(item.owner.login)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 4)
  }
}
