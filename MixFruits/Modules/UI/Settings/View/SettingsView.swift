//
//  SettingsView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("settings.enableTimers") private var enableTimers: Bool = true
    @AppStorage("settings.showHints") private var showHints: Bool = true

    @State private var showClearImagesConfirmation = false
    @State private var showResetRecipesConfirmation = false
    @State private var infoMessage: String?


    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("App Behaviour")) {
                    Toggle("Enable cooking timers", isOn: $enableTimers)
                    Toggle("Show tips and hints", isOn: $showHints)
                }

                Section(header: Text("Privacy & Data")) {
                    Button(role: .destructive) {
                        showClearImagesConfirmation = true
                    } label: {
                        Label("Clear saved images", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    Button(role: .destructive) {
                        showResetRecipesConfirmation = true
                    } label: {
                        Label("Reset recipes to bundled sample", systemImage: "arrow.counterclockwise")
                    }
                    HStack {
                        Spacer()
                        Button {
                            // Open privacy policy in device browser
                            if let url = URL(string: "https://example.com/privacy") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        } label: {
                            Text("Privacy Policy")
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                    .padding(.top, 8)
                }

                if let msg = infoMessage {
                    Section {
                        Text(msg)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement: .confirmationAction) { EmptyView() } }
            .confirmationDialog("Are you sure?", isPresented: $showClearImagesConfirmation, titleVisibility: .visible) {
                Button("Clear all saved images", role: .destructive) {
                    clearSavedImages()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all images saved by the app (main and stage images).")
            }

            .confirmationDialog("Reset recipes to sample?", isPresented: $showResetRecipesConfirmation, titleVisibility: .visible) {
                Button("Reset recipes", role: .destructive) {
                    resetRecipesToSample()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove any recipes you created or saved and restore the bundled sample recipes. This action cannot be undone.")
            }
        }
    }

    // MARK: - Actions
    private func clearSavedImages() {
        let files = ImageFileStorage.listSavedImages()
        for f in files { ImageFileStorage.deleteImage(named: f) }
        infoMessage = files.isEmpty ? "No saved images were found." : "Deleted \(files.count) saved image(s)."
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { infoMessage = nil }
    }

    private func resetRecipesToSample() {
        do {
            let store = RecipeStore()
            try store.deleteStore()
            infoMessage = "Recipes reset — restart app or reload library to see sample recipes."
        } catch {
            infoMessage = "Failed to reset recipes: \(error.localizedDescription)"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { infoMessage = nil }
    }
}

#Preview {
    SettingsView()
}
