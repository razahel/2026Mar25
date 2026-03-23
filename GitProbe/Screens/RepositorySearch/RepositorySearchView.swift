import SwiftUI

struct RepositorySearchView: View {
  @ObservedObject var viewModel: RepositorySearchViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.searchTitle.text)
        .font(.largeTitle)
        .bold()
        .padding(.top, 8)
      
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .foregroundStyle(.secondary)
        TextField(L10N.searchPlaceholder.text, text: $viewModel.query)
          .submitLabel(.search)
          .onSubmit {
            viewModel.didTapSearch()
          }
        
        if !viewModel.query.isEmpty {
          Button {
            viewModel.query = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.secondary)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background(Color(.secondarySystemFill))
      .clipShape(RoundedRectangle(cornerRadius: 8))
      
      contentView
    }
    .padding(.horizontal, 16)
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
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
        Text(L10N.recentTitle.text)
          .font(.headline)
        Spacer()
        if !viewModel.recentSearches.isEmpty {
          Button(L10N.recentDeleteAll.text) {
            viewModel.deleteAllRecentSearches()
          }
          .font(.caption)
          .foregroundStyle(.pink)
        }
      }
      
      ForEach(viewModel.recentSearches) { item in
        HStack {
          Button(item.keyword) {
            viewModel.didTapRecentSearch(item)
          }
          .buttonStyle(.plain)
          .foregroundStyle(.primary)
          
          Spacer()
          
          Button {
            viewModel.deleteRecentSearch(keyword: item.keyword)
          } label: {
            Image(systemName: "xmark")
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
          viewModel.didTapAutocomplete(item)
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
            viewModel.loadNextPageIfNeeded(currentItem: item)
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
