//
//  MainContentView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.01.26.
//

import SwiftUI
import DarkCoreFramework

struct MainContentView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        router.changeScreen()
    }
}

#Preview {
    var darkCore = DarkCore.configure(config: Configuration(
        appsDevKey: "7N9GPhHowZLgGHEPPu5feg",
        appleAppId: "6756780702"
    ), clearView: ContentView())
   
    MainContentView()
        .environmentObject(darkCore)
}
