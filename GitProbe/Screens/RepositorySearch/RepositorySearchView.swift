import SwiftUI

struct RepositorySearchView: View {
  @StateObject private var viewModel: RepositorySearchViewModel
  
  init(viewModel: RepositorySearchViewModel) {
    _viewModel = StateObject(
      wrappedValue: viewModel
    )
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(Localizable.searchTitle.text)
        .font(.largeTitle)
        .bold()
        .padding(.top, 8)
      searchInputView
      contentView
    }
    .padding(.horizontal, 16)
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.onAppear()
    }
    .alert(Localizable.commonErrorTitle.text, isPresented: Binding(
      get: { viewModel.errorMessage != nil },
      set: { if !$0 { viewModel.errorMessage = nil } }
    )) {
      Button(Localizable.commonConfirm.text, role: .cancel) { }
    } message: {
      Text(viewModel.errorMessage ?? "")
    }
  }
  
  private var searchInputView: some View {
    HStack(spacing: 8) {
      Image(systemName: Assets.magnifyingglass.name)
        .foregroundStyle(.secondary)
      TextField(Localizable.searchPlaceholder.text, text: $viewModel.query)
        .submitLabel(.search)
        .onSubmit {
          viewModel.onTapSearch()
        }
      
      if !viewModel.query.isEmpty {
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
    if viewModel.showRecentSearches {
      recentSearchView
    } else if viewModel.showAutocomplete {
      autocompleteView
    } else if viewModel.isInitialLoading {
      Spacer()
      HStack {
        Spacer()
        ProgressView()
        Spacer()
      }
      Spacer()
    } else {
      resultView
    }
  }
  
  private var recentSearchView: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(Localizable.recentTitle.text)
          .font(.headline)
        Spacer()
        if !viewModel.recentSearches.isEmpty {
          Button(Localizable.recentDeleteAll.text) {
            viewModel.onTapDeleteAllRecentSearches()
          }
          .font(.caption)
          .foregroundStyle(.pink)
        }
      }
      
      ForEach(viewModel.recentSearches) { item in
        HStack {
          Button(item.keyword) {
            viewModel.onTapRecentSearch(item)
          }
          .buttonStyle(.plain)
          .foregroundStyle(.primary)
          
          Spacer()
          
          Button {
            viewModel.onTapDeleteRecentSearch(keyword: item.keyword)
          } label: {
            Image(systemName: Assets.xmark.name)
              .foregroundStyle(.secondary)
          }
          .buttonStyle(.plain)
        }
        .font(.subheadline)
      }
      
      Spacer()
    }
  }
  
  private var autocompleteView: some View {
    List {
      ForEach(viewModel.autocompleteItems) { item in
        Button {
          viewModel.onTapAutocomplete(item)
        } label: {
          HStack {
            Text(item.keyword)
              .foregroundStyle(.primary)
            Spacer()
            Text(viewModel.formattedDate(item.searchedAt))
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
      Text(viewModel.localizedResultCountText)
        .font(.caption)
        .foregroundStyle(.secondary)
      
      List {
        ForEach(viewModel.repositories) { item in
          NavigationLink {
            RepositoryWebScreen(repositoryURL: item.htmlURL)
          } label: {
            RepositoryRowView(item: item)
          }
          .onAppear {
            viewModel.onAppearRepositoryItem(item)
          }
        }
        
        if viewModel.isNextPageLoading {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
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
