//
//  MixFruitsApp.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI
import Swinject

@main
struct MixFruitsApp: App {
    // Simple Swinject container setup for the app
    private let container: Container = {
        let c = Container()
        // Register RecipeStore as a singleton
        c.register(RecipeStore.self) { _ in RecipeStore() }
            .inObjectScope(.container)

        // Register LibraryViewModel and inject RecipeStore
        c.register(LibraryViewModel.self) { r in
            let store = r.resolve(RecipeStore.self)!
            return LibraryViewModel(store: store)
        }

        // Register BookmarkViewModel and inject the same RecipeStore
        c.register(BookmarkViewModel.self) { r in
            let store = r.resolve(RecipeStore.self)!
            return BookmarkViewModel(store: store)
        }
        return c
    }()

    var body: some Scene {
        WindowGroup {
                // Resolve the LibraryViewModel and BookmarkViewModel and pass into ContentView
                let libraryVM = container.resolve(LibraryViewModel.self)
                let bookmarkVM = container.resolve(BookmarkViewModel.self)
                ContentView(libraryVM: libraryVM, bookmarkVM: bookmarkVM)
        }
    }
}
