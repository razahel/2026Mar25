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
    RepositoryWebContainerView(url: viewModel.url)
      .ignoresSafeArea(edges: .bottom)
  }
}

private struct RepositoryWebContainerView: UIViewRepresentable {
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
