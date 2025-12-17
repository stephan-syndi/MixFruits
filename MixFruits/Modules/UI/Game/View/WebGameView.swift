//
//  WebGameView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI
import WebKit

struct WebGameView: View {
    @StateObject private var viewModel = WebGameViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ZStack {
                    Color.brown.ignoresSafeArea()

                    WebView(viewModel: viewModel)

                    if viewModel.isLoading {
                        Color.brown.ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .alert(item: $viewModel.errorMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    WebGameView()
}
