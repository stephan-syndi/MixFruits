import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebGameViewModel

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // KVO for loading/progress could be added here; we'll rely on delegate callbacks
        viewModel.assign(webView: webView)

        if let url = URL(string: viewModel.urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // If the viewModel's urlString differs from the current webView URL, load it.
        if let current = uiView.url?.absoluteString, current != viewModel.urlString {
            if let url = URL(string: viewModel.urlString) {
                uiView.load(URLRequest(url: url))
            }
        }

        // Update state flags
        viewModel.assign(webView: uiView)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
            super.init()
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewModel.startLoading()
            parent.viewModel.updateStateFromWebView()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Keep progress visible for a short delay after finish
            parent.viewModel.finishLoadingWithDelay(5.0)
            parent.viewModel.updateStateFromWebView()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.cancelPendingHide()
            parent.viewModel.errorMessage = WebError(message: error.localizedDescription)
            parent.viewModel.updateStateFromWebView()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.cancelPendingHide()
            parent.viewModel.errorMessage = WebError(message: error.localizedDescription)
            parent.viewModel.updateStateFromWebView()
        }
    }
}
