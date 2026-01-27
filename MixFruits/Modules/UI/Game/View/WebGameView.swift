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
        if #available(iOS 16.0, *) {
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
        } else {
            // Fallback on earlier versions
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
