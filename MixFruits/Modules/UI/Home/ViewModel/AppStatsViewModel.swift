//
//  AppStatsViewModel.swift
//  MixFruits
//
//  Created by GitHub Copilot on 04.12.25.
//

import Foundation
import SwiftUI
internal import Combine

/// Simple recent action model
struct RecentAction: Identifiable {
    var id = UUID()
    var title: String
    var date: Date = Date()
}

/// Aggregates simple app statistics from sample data sources.
class AppStatsViewModel: ObservableObject {
    @Published var bookmarksCount: Int = 0
    @Published var doneRecipeCount: Int = 0
    @Published var lastRecipe: Recipe? = nil
    @Published var recentActions: [RecentAction] = []

    // For this prototype we create local view models and derive stats
    private var bookmarksVM = BookmarkViewModel()
    private var libraryVM = LibraryViewModel()

    init() {
        // Observe recipe viewed events to update lastRecipe reactively
        NotificationCenter.default.addObserver(self, selector: #selector(recipeViewed(_:)), name: .mixfruitsRecipeViewed, object: nil)
        // Also observe bookmark changes to update counts
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarksChanged(_:)), name: .mixfruitsAddBookmark, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarksChanged(_:)), name: .mixfruitsRemoveBookmark, object: nil)

        refresh()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func bookmarksChanged(_ note: Notification) {
        // simple refresh of counts
        bookmarksCount = BookmarkViewModel().bookmarks.count
    }

    @objc private func recipeViewed(_ note: Notification) {
        if let recipe = note.object as? Recipe {
            DispatchQueue.main.async {
                self.lastRecipe = recipe
                // prepend recent action
                self.recentActions.insert(RecentAction(title: "Viewed: \(recipe.title)", date: Date()), at: 0)
                // cap recent actions
                if self.recentActions.count > 10 { self.recentActions.removeLast() }
            }
        }
    }

    func refresh() {
        bookmarksCount = bookmarksVM.bookmarks.count

        // Treat recipes with rating > 0 as 'done' for demo purposes
        doneRecipeCount = libraryVM.recipes.filter { $0.rating > 0 }.count

        // last recipe: prefer last bookmarked or first library sample
        lastRecipe = bookmarksVM.bookmarks.first ?? libraryVM.recipes.first

        // Build a simple recent actions list
        recentActions = []
        if let r = lastRecipe {
            recentActions.append(RecentAction(title: "Viewed: \(r.title)", date: Date()))
        }
        if bookmarksCount > 0 {
            recentActions.append(RecentAction(title: "You have \(bookmarksCount) bookmarks"))
        }
        recentActions.append(RecentAction(title: "Recipes in library: \(libraryVM.recipes.count)"))
    }
}
