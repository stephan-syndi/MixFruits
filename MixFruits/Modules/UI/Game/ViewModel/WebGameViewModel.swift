import Foundation
import WebKit
internal import Combine

final class WebGameViewModel: ObservableObject {
    @Published var urlString: String = "https://play.unity.com/api/v1/games/game/86c70f6d-6565-44b9-a9d1-e40c834764f3/build/latest/frame"
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var errorMessage: WebError?

    // Weak reference to underlying WKWebView controlled by the WebView wrapper.
    fileprivate weak var webView: WKWebView?
    private var hideProgressWorkItem: DispatchWorkItem?

    func assign(webView: WKWebView) {
        self.webView = webView
        updateStateFromWebView()
    }

    /// Called when navigation starts; ensure progress is visible and cancel any pending hide.
    func startLoading() {
        DispatchQueue.main.async {
            self.hideProgressWorkItem?.cancel()
            self.hideProgressWorkItem = nil
            self.isLoading = true
        }
    }

    /// Called when navigation finishes; keep the progress visible for a short delay before hiding.
    func finishLoadingWithDelay(_ seconds: TimeInterval = 5.0) {
        DispatchQueue.main.async {
            self.hideProgressWorkItem?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.isLoading = false
                self?.hideProgressWorkItem = nil
            }
            self.hideProgressWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
            // Keep isLoading true until the work item runs
            self.isLoading = true
        }
    }

    /// Cancel any pending hide-work and immediately hide the progress.
    func cancelPendingHide() {
        DispatchQueue.main.async {
            self.hideProgressWorkItem?.cancel()
            self.hideProgressWorkItem = nil
            self.isLoading = false
        }
    }

    func loadCurrent() {
        var str = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !str.isEmpty else { return }
        if !str.contains("://") {
            str = "https://" + str
        }
        guard let url = URL(string: str) else {
            errorMessage = WebError(message: "Invalid URL")
            return
        }
        let req = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView?.load(req)
        }
    }

    func goBack() {
        DispatchQueue.main.async {
            self.webView?.goBack()
        }
    }

    func goForward() {
        DispatchQueue.main.async {
            self.webView?.goForward()
        }
    }

    func reload() {
        DispatchQueue.main.async {
            self.webView?.reload()
        }
    }

    func updateStateFromWebView() {
        DispatchQueue.main.async {
            guard let w = self.webView else { return }
            if w.isLoading {
                self.isLoading = true
            } else {
                // If there's a pending delayed hide, keep showing progress until that work item runs.
                if self.hideProgressWorkItem == nil {
                    self.isLoading = false
                }
            }
            self.canGoBack = w.canGoBack
            self.canGoForward = w.canGoForward
            if let url = w.url {
                self.urlString = url.absoluteString
            }
        }
    }
}

// Simple wrapper to present errors via Alert using Identifiable
struct WebError: Identifiable {
    let id = UUID()
    let message: String
}
