//
//  ContentView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI

struct ContentView: View {
    // Allow injecting a LibraryViewModel from the app container
    var libraryVM: LibraryViewModel?
    var bookmarkVM: BookmarkViewModel?

    var body: some View {
        ZStack {
            Design.backgroundGradient
                .ignoresSafeArea()

            TabView(){
                HomeView()
                    .tabItem{
                        Label("Home", systemImage: "house.fill")
                    }
                LibraryView(vm: libraryVM ?? LibraryViewModel())
                    .tabItem{
                        Label("Library", systemImage: "books.vertical.fill")
                    }
                BookmarkView(vm: bookmarkVM ?? BookmarkViewModel())
                    .tabItem{
                        Label("Bookmarks", systemImage: "bookmark.fill")
                    }
                WebGameView()
                    .tabItem{
                        Label("Game", systemImage: "gamecontroller.fill")
                    }
                SettingsView()
                    .tabItem{
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
