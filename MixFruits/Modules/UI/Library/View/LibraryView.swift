//
//  LibraryView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI

struct LibraryView: View {
    @StateObject var vm: LibraryViewModel
    @State private var showFilters: Bool = false

    init(vm: LibraryViewModel = LibraryViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Design.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Search + Filter row
                    HStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search recipes", text: $vm.searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Design.cardBackground).shadow(color: Design.softShadow, radius: 4, x: 0, y: 2))

                        Button {
                            withAnimation { showFilters.toggle() }
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .imageScale(.large)
                        }
                    }
                    .padding(.horizontal)
                    
                    if showFilters {
                        // Reusable filter panel (search always visible)
                        FilterPanel(
                            maxIngredients: Binding(get: { vm.maxIngredients }, set: { vm.maxIngredients = $0 }),
                            minTime: Binding(get: { vm.minTime }, set: { vm.minTime = $0 }),
                            maxTime: Binding(get: { vm.maxTime }, set: { vm.maxTime = $0 }),
                            difficulty: Binding(get: { vm.difficulty }, set: { vm.difficulty = $0 }),
                            category: Binding(get: { vm.selectedCategory }, set: { vm.selectedCategory = $0 })
                        )
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .background(Design.elevatedCard)
                    }
                    
                    // List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.filteredRecipes, id: \.id) { recipe in
                                NavigationLink(value: recipe) {
                                    RecipeCardView(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical)
                    }
                    .navigationDestination(for: Recipe.self) { recipe in
                        RecipeDetailView(recipe: recipe)
                    }
                }
                .navigationTitle("Library")
            }
        }
    }
}

#Preview {
    LibraryView()
}
