//
//  LibraryViewModel.swift
//  MixFruits
//
//  Created by GitHub Copilot on 04.12.25.
//

import Foundation
import SwiftUI
internal import Combine

class LibraryViewModel: ObservableObject {
    // Source data
    @Published var recipes: [Recipe] = []

    // Search & filters
    @Published var searchText: String = ""
    @Published var maxIngredients: Int = 10
    @Published var minTime: Int = 0
    @Published var maxTime: Int = 120
    @Published var difficulty: Difficulty = .any
    @Published var selectedCategory: Category = .all

    private let store: RecipeStore

    init(store: RecipeStore = RecipeStore()) {
        self.store = store
        // Always load recipes from the bundled sample JSON for the library view.
        if !loadBundledSample() {
            // If bundled decoding fails, fall back to in-code sample dataset.
            loadSampleData()
        }

        // Observe bookmark add/remove notifications and update local recipe flags.
        NotificationCenter.default.addObserver(self, selector: #selector(handleAddBookmarkNotification(_:)), name: .mixfruitsAddBookmark, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRemoveBookmarkNotification(_:)), name: .mixfruitsRemoveBookmark, object: nil)
        // Merge any persisted bookmarks so bundled library items reflect bookmarked state.
        mergePersistedBookmarks()
    }

    /// Attempt to load recipes from the bundled `sample_recipes.json` resource.
    /// - Returns: `true` if loading and decoding succeeded, `false` otherwise.
    @discardableResult
    private func loadBundledSample() -> Bool {
        guard let bundleURL = Bundle.main.url(forResource: "sample_recipes", withExtension: "json") else {
            print("LibraryViewModel: bundled sample_recipes.json not found in bundle")
            return false
        }

        do {
            let data = try Data(contentsOf: bundleURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode([Recipe].self, from: data)
            DispatchQueue.main.async {
                self.recipes = decoded
            }
            return true
        } catch {
            print("LibraryViewModel: failed to decode bundled sample_recipes.json:", error)
            return false
        }
    }

    func persistRecipes() {
        do {
            try store.save(recipes)
        } catch {
            print("Failed to save recipes: \(error)")
        }
    }

    func loadSampleData() {
        recipes = [
            Recipe(title: "Chocolate Cake", subtitle: "Rich & moist", steps: 12, minutes: 45, rating: 4, isBookmarked: false, imageName: "birthday.cake", ingredientsCount: 8, difficulty: .medium, category: .baking, stages: [
                Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
                Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
            ]),
            Recipe(title: "Berry Smoothie", subtitle: "Fresh & quick", steps: 5, minutes: 8, rating: 5, isBookmarked: false, imageName: "leaf", ingredientsCount: 4, difficulty: .easy, category: .smoothie, stages: [
                Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
                Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
            ]),
            Recipe(title: "Apple Pie", subtitle: "Classic dessert", steps: 10, minutes: 70, rating: 4, isBookmarked: false, imageName: "applelogo", ingredientsCount: 10, difficulty: .medium, category: .sweets, stages: [
                Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
                Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
            ]),
            Recipe(title: "Tomato Soup", subtitle: "Cozy hot dish", steps: 6, minutes: 30, rating: 3, isBookmarked: false, imageName: "drop", ingredientsCount: 6, difficulty: .easy, category: .hot, stages: [
                Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
                Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
            ]),
        ]
    }

    var filteredRecipes: [Recipe] {
        recipes.filter { r in
            // Search
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || r.title.localizedCaseInsensitiveContains(searchText)

            // Ingredients filter: use ingredientsCount field
            let matchesIngredients = r.ingredientsCount <= maxIngredients

            // Time range
            let matchesTime = r.minutes >= minTime && r.minutes <= maxTime

            // Difficulty: match if filter is .any or equals recipe difficulty
            let matchesDifficulty = (difficulty == .any) || (r.difficulty == difficulty)

            // Category: match directly against recipe.category unless 'all'
            let matchesCategory = (selectedCategory == .all) || (r.category == selectedCategory)

            return matchesSearch && matchesIngredients && matchesTime && matchesDifficulty && matchesCategory
        }
    }

    @objc private func handleAddBookmarkNotification(_ note: Notification) {
        guard let recipe = note.object as? Recipe else { return }
        if let idx = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[idx].isBookmarked = true
        }
    }

    @objc private func handleRemoveBookmarkNotification(_ note: Notification) {
        guard let recipe = note.object as? Recipe else { return }
        if let idx = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[idx].isBookmarked = false
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// If there are persisted bookmarked recipes in Documents, mark matching bundled recipes as bookmarked.
    private func mergePersistedBookmarks() {
        DispatchQueue.global(qos: .utility).async {
            do {
                let persisted = try self.store.loadPersisted()
                let bookmarkedIDs = Set(persisted.filter { $0.isBookmarked }.map { $0.id })
                if !bookmarkedIDs.isEmpty {
                    DispatchQueue.main.async {
                        for idx in self.recipes.indices {
                            if bookmarkedIDs.contains(self.recipes[idx].id) {
                                self.recipes[idx].isBookmarked = true
                            }
                        }
                    }
                }
            } catch {
                // ignore - persisted file may not exist
            }
        }
    }
}
