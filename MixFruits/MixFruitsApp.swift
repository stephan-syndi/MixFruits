//
//  MixFruitsApp.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI
import Swinject
import AppTrackingTransparency
import AdSupport
import DarkCoreFramework

@main
struct MixFruitsApp: App {
    @UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate
    let config = Configuration(
        appsDevKey: "7N9GPhHowZLgGHEPPu5feg",
        appleAppId: "6756780702",
        backIsImage: true
    )

    private let router: AppRouter
    
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
    
    init(){
        print("👉 init MyApp")
        let libraryVM = container.resolve(LibraryViewModel.self)
        let bookmarkVM = container.resolve(BookmarkViewModel.self)
        router = DarkCore.configure(config: config, clearView: ContentView(libraryVM: libraryVM, bookmarkVM: bookmarkVM))
        router.setScreen(screen: .clear, view: ContentView(libraryVM: libraryVM, bookmarkVM: bookmarkVM))
        router.setScreen(screen: .curtain, view: CurtainView())
        router.setScreen(screen: .permission, view: PermissionView(viewModel: router.getPermissionViewModel()))
        router.setScreen(screen: .internet, view: InternetAlertView())
        appDelegate.router = router
    }

    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(router)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { requestTrackingPermission() }
                }
        }
    }
    
    // ToDo: delete after adding gray side
    private func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
            }
        }
    }
}
