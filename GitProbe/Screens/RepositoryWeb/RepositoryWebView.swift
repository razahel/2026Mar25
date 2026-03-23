import SwiftUI
import WebKit

struct RepositoryWebView: UIViewRepresentable {
  @ObservedObject var viewModel: RepositoryWebViewModel
  
  func makeUIView(context: Context) -> WKWebView {
    WKWebView(frame: .zero)
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    let request = URLRequest(url: viewModel.repositoryURL)
    if webView.url != viewModel.repositoryURL {
      webView.load(request)
    }
  }
}
