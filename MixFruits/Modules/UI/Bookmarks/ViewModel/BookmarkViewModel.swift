//
//  BookmarkViewModel.swift
//  MixFruits
//
//  Created by GitHub Copilot on 04.12.25.
//

import Foundation
import SwiftUI
internal import Combine

class BookmarkViewModel: ObservableObject {
    @Published var bookmarks: [Recipe] = []
    @Published var drafts: [RecipeDraft] = []
    @Published var toastMessage: String? = nil

    private let store: RecipeStore
    private let draftStore: DraftStore
    private var cancellables = Set<AnyCancellable>()

    init(store: RecipeStore = RecipeStore()) {
        self.store = store
        self.draftStore = DraftStore()

        // Listen to bookmark add/remove notifications from other parts of the app
        NotificationCenter.default.addObserver(self, selector: #selector(handleAddNotification(_:)), name: .mixfruitsAddBookmark, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRemoveNotification(_:)), name: .mixfruitsRemoveBookmark, object: nil)

        // Try to load persisted bookmarks from Documents; fall back to sample data
        do {
            let loaded = try store.loadPersisted()
            if loaded.isEmpty {
//                loadSample()
            } else {
                bookmarks = loaded
            }
        } catch {
            print("BookmarkViewModel: failed to load persisted bookmarks:", error)
//            loadSample()
        }

        // Persist bookmarks whenever they change (debounced)
        $bookmarks
            .receive(on: DispatchQueue.global(qos: .utility))
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] list in
                guard let self = self else { return }
                do {
                    try self.store.save(list)
                } catch {
                    print("Bookmark persist error: \(error)")
                }
            }
            .store(in: &cancellables)

        // Load persisted drafts and persist on changes
        do {
            let loadedDrafts = try draftStore.load()
            if !loadedDrafts.isEmpty {
                drafts = loadedDrafts
            }
        } catch {
            // keep any sample drafts already populated
            print("DraftStore load error:", error)
        }

        $drafts
            .receive(on: DispatchQueue.global(qos: .utility))
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] list in
                guard let self = self else { return }
                do {
                    try self.draftStore.save(list)
                } catch {
                    print("Draft persist error: \(error)")
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Storage helpers

    /// Delete the persisted drafts file from disk.
    func deleteDraftStoreFile() {
        do {
            try draftStore.deleteStore()
            DispatchQueue.main.async {
                self.drafts.removeAll()
                self.showToast("Файл черновиков удалён")
            }
            // After removing drafts, clean up any unreferenced images
            cleanupUnusedImages()
        } catch {
            print("Failed to delete drafts store:", error)
        }
    }

    private func showToast(_ text: String) {
        DispatchQueue.main.async {
            self.toastMessage = text
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { self.toastMessage = nil }
            }
        }
    }

    /// Delete image files in Documents that are not referenced by any bookmark or draft.
    func cleanupUnusedImages() {
        DispatchQueue.global(qos: .utility).async {
            var used = Set<String>()
            // Bookmarks
            for r in self.bookmarks {
                if let n = r.imageName { used.insert(n) }
            }
            // Drafts: main and stages
            for d in self.drafts {
                if let n = d.mainImageName { used.insert(n) }
                for s in d.stages {
                    if let n = s.imageName { used.insert(n) }
                }
            }

            // List saved images and delete those not in 'used'
            let all = ImageFileStorage.listSavedImages()
            for file in all {
                if !used.contains(file) {
                    ImageFileStorage.deleteImage(named: file)
                }
            }
        }
    }

    func loadSample() {
        // keep demo data small
        bookmarks = [
            Recipe(title: "Chocolate Cake", subtitle: "Rich & moist", steps: 12, minutes: 45, rating: 4, isBookmarked: true, imageName: "birthday.cake", ingredientsCount: 8, difficulty: .medium, category: .baking, stages: [
                Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
                Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
            ]),
            Recipe(title: "Berry Smoothie", subtitle: "Fresh & quick", steps: 5, minutes: 8, rating: 5, isBookmarked: true, imageName: "leaf", ingredientsCount: 4, difficulty: .easy, category: .smoothie, stages: [
                Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
                Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
            ])
        ]
    }

    func addBookmark(_ recipe: Recipe) {
        var r = recipe
        r.isBookmarked = true
        bookmarks.insert(r, at: 0)
        // Clean up unused images and show notification
        cleanupUnusedImages()
        showToast("Закладка сохранена")
    }

    func removeBookmark(_ recipe: Recipe) {
        bookmarks.removeAll { $0.id == recipe.id }
    }

    func saveDraft(_ draft: RecipeDraft) {
        if let idx = drafts.firstIndex(where: { $0.id == draft.id }) {
            drafts[idx] = draft
        } else {
            drafts.insert(draft, at: 0)
        }
        cleanupUnusedImages()
        showToast("Черновик сохранён")
    }

    func removeDraft(_ draft: RecipeDraft) {
        drafts.removeAll { $0.id == draft.id }
        cleanupUnusedImages()
        showToast("Черновик удалён")
    }

    @objc private func handleAddNotification(_ note: Notification) {
        guard let recipe = note.object as? Recipe else { return }
        // avoid duplicates
        if !bookmarks.contains(where: { $0.id == recipe.id }) {
            addBookmark(recipe)
        }
    }

    @objc private func handleRemoveNotification(_ note: Notification) {
        guard let recipe = note.object as? Recipe else { return }
        removeBookmark(recipe)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
