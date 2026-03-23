import SwiftUI
import WebKit

struct RepositoryWebView: UIViewRepresentable {
  let url: URL
  
  func makeUIView(context: Context) -> WKWebView {
    WKWebView(frame: .zero)
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    if webView.url != url {
      webView.load(request)
    }
  }
}
