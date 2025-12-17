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
        refresh()
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
