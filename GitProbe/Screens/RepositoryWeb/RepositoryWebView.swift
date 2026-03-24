//
//  RepositoryWebView.swift
//  GitProbe
//
//  Created by Yoon Kang on 24/3/26.
//

import SwiftUI
import WebKit

struct RepositoryWebView: View {
  @ObservedObject var viewModel: RepositoryWebViewModel
  
  var body: some View {
    ZStack {
      RepositoryWebContainerView(url: viewModel.url, isLoading: $viewModel.isLoading)
        .ignoresSafeArea(edges: .bottom)
      
      if viewModel.isLoading {
        ProgressView()
          .controlSize(.large)
      }
    }
  }
}

private struct RepositoryWebContainerView: UIViewRepresentable {
  let url: URL
  @Binding var isLoading: Bool
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView(frame: .zero)
    webView.navigationDelegate = context.coordinator
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    if webView.url != url {
      isLoading = true
      webView.load(request)
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(isLoading: $isLoading)
  }
  
  final class Coordinator: NSObject, WKNavigationDelegate {
    @Binding private var isLoading: Bool
    
    init(isLoading: Binding<Bool>) {
      _isLoading = isLoading
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      isLoading = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      isLoading = false
    }
  }
}
