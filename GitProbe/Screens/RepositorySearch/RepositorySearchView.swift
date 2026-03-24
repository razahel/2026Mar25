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
    .padding(.horizontal, 16)
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
    .padding(.horizontal, 16)
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
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        HStack {
          Text(Localizable.recentTitle.string)
            .font(.subheadline.pointSize(16).weight(.semibold))
          Spacer()
          if viewModel.recentSearches.isEmpty == false {
            Button(Localizable.recentDeleteAll.string) {
              viewModel.onTapDeleteAllRecentSearches()
            }
            .font(.caption2.pointSize(14))
            .foregroundStyle(.pink)
          }
        }
        .frame(height: 32)

        if viewModel.recentSearches.isEmpty {
          Text(Localizable.searchPlaceholder.string)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
        } else {
          WrapLayout(spacing: 8, lineSpacing: 8) {
            ForEach(viewModel.recentSearches) { item in
              HStack(spacing: 6) {
                Button(item.keyword) {
                  isSearchFieldFocused = false
                  viewModel.onTapRecentSearch(item)
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
                .buttonStyle(.plain)
                
                Button {
                  viewModel.onTapDeleteRecentSearch(keyword: item.keyword)
                } label: {
                  Image(systemName: Assets.xmark.name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
              }
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(Color(.secondarySystemFill))
              .clipShape(Capsule())
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }

        Spacer(minLength: 0)
      }
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .scrollBounceBehavior(.always)
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
        .padding(.horizontal, 16)
      
      List {
        ForEach(viewModel.repositories) { item in
          NavigationLink {
            RepositoryWebScreen(
              dependency: viewModel.repositorWebDependency,
              url: item.htmlURL,
              repository: item
            )
          } label: {
            repositoryRowView(item: item)
          }
          .onAppear {
            viewModel.onAppearRepositoryItem(item)
          }
        }
      }
      .listStyle(.plain)
    }
  }

  @ViewBuilder
  private func repositoryRowView(item: RepositorySearchItem) -> some View {
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
