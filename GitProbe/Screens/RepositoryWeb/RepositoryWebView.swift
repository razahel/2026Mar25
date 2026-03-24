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
    VStack(spacing: 0) {
      ZStack(alignment: .leading) {
        Color.clear
          .frame(height: 2)
          .frame(maxWidth: .infinity)
        if viewModel.loadingProgress > 0 {
          ProgressView(value: viewModel.loadingProgress, total: 1)
            .progressViewStyle(.linear)
            .tint(.accentColor)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.22), value: viewModel.loadingProgress)
        }
      }
      .frame(height: 2)
      .frame(maxWidth: .infinity)
      RepositoryWebContainerView(url: viewModel.url, loadingProgress: $viewModel.loadingProgress)
        .ignoresSafeArea(edges: .bottom)
    }
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        HStack(spacing: 8) {
          AsyncImage(url: viewModel.repository.owner.avatarURL) { phase in
            switch phase {
            case .success(let image):
              image.resizable().scaledToFill()
            default:
              Color(.systemGray5)
            }
          }
          .frame(width: 24, height: 24)
          .clipShape(Circle())
          
          Text(viewModel.repository.name)
            .font(.headline)
            .lineLimit(1)
          
          Spacer()
        }
      }
    }
  }
}

private struct RepositoryWebContainerView: UIViewRepresentable {
  let url: URL
  @Binding var loadingProgress: Double
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView(frame: .zero)
    webView.navigationDelegate = context.coordinator
    context.coordinator.startObservingProgress(of: webView)
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    if webView.url != url {
      webView.load(request)
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(loadingProgress: $loadingProgress)
  }
  
  final class Coordinator: NSObject, WKNavigationDelegate {
    @Binding private var loadingProgress: Double
    private var progressObservation: NSKeyValueObservation?
    
    init(loadingProgress: Binding<Double>) {
      _loadingProgress = loadingProgress
    }
    
    deinit {
      progressObservation?.invalidate()
    }
    
    func startObservingProgress(of webView: WKWebView) {
      progressObservation = webView.observe(\.estimatedProgress, options: [.new, .initial]) { [weak self] webView, _ in
        guard let self else { return }
        DispatchQueue.main.async {
          self.loadingProgress = max(min(webView.estimatedProgress, 1), 0)
        }
      }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      loadingProgress = 0
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      loadingProgress = 0
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      loadingProgress = 0
    }
  }
}
