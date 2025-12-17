//
//  BookmarkView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI

struct BookmarkView: View {
    @StateObject var vm: BookmarkViewModel
    @State private var showBuilder: Bool = false
    @State private var selectedTab: Int = 0 // 0 = Bookmarks, 1 = Drafts
    @State private var editingDraft: RecipeDraft? = nil
    // Search & filter state for Bookmarks
    @State private var searchText: String = ""
    @State private var showFiltersPanel: Bool = false
    @State private var maxIngredients: Int = 10
    @State private var minTime: Int = 0
    @State private var maxTime: Int = 240
    @State private var difficultyFilter: Difficulty = .any
    @State private var categoryFilter: Category = .all
    
    // Computed filtered array based on search and filters
    private var filteredBookmarks: [Recipe] {
        vm.bookmarks.filter { r in
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || r.title.localizedCaseInsensitiveContains(searchText)
            let matchesIngredients = r.ingredientsCount <= maxIngredients
            let matchesTime = r.minutes >= minTime && r.minutes <= maxTime
            // Difficulty: match if filter is .any or equals recipe difficulty
            let matchesDifficulty = (difficultyFilter == .any) || (r.difficulty == difficultyFilter)
            
            // Category: match directly against recipe.category unless 'all'
            let matchesCategory = (categoryFilter == .all) || (r.category == categoryFilter)
            
            return matchesSearch && matchesIngredients && matchesTime && matchesDifficulty && matchesCategory
        }
    }
    
    init(vm: BookmarkViewModel = BookmarkViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Design.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Top segmented picker and add button
                    HStack {
                        Picker("", selection: $selectedTab) {
                            Text("Bookmarks").tag(0)
                            Text("Drafts").tag(1)
                        }
                        .pickerStyle(.segmented)
                        
                        Spacer()
                        
                        Button {
                            // Open builder for a new recipe
                            editingDraft = nil
                            showBuilder = true
                        } label: {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Design.primary).opacity(0.12))
                        }
                    }
                    .padding(.horizontal)
                    
                    if selectedTab == 1 {
                        // Drafts view — keep the drafts area a full-height container so
                        // the empty state doesn't push other UI elements down.
                        VStack {
                            if vm.drafts.isEmpty {
                                Spacer()
                                Text("No drafts yet")
                                    .foregroundColor(.secondary)
                                    .padding()
                                Spacer()
                            } else {
                                List {
                                    ForEach(vm.drafts) { draft in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(draft.title).bold()
                                                Text(draft.subtitle).font(.caption).foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Button("Edit") {
                                                editingDraft = draft
                                                showBuilder = true
                                            }
                                        }
                                        .padding(.vertical, 6)
                                    }
                                    .onDelete { idx in
                                        idx.map { vm.removeDraft(vm.drafts[$0]) }
                                    }
                                }
                                .listStyle(.inset)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Search + filter toggle
                        HStack(spacing: 8) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search bookmarks", text: $searchText)
                                    .textFieldStyle(.plain)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemBackground)).shadow(color: Design.softShadow, radius: 1, x: 0, y: 1))

                            Button {
                                withAnimation { showFiltersPanel.toggle() }
                            } label: {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                    .imageScale(.large)
                            }
                        }
                        .padding(.horizontal)

                        if showFiltersPanel {
                            FilterPanel(maxIngredients: $maxIngredients, minTime: $minTime, maxTime: $maxTime, difficulty: $difficultyFilter, category: $categoryFilter)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground)))
                                .padding(.horizontal)
                        }
                        // Bookmarked recipes list
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredBookmarks, id: \.id) { recipe in
                                    NavigationLink(value: recipe) {
                                        RecipeCardView(recipe: recipe)
                                    }
                                    .contextMenu {
                                        Button("Remove") {
                                            vm.removeBookmark(recipe)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .navigationTitle("Bookmarks")
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeDetailView(recipe: recipe)
                }
                .sheet(isPresented: $showBuilder) {
                    if let draft = editingDraft {
                        RecipeBuilderView(draft: draft, onSave: { recipe in
                            vm.addBookmark(recipe)
                        }, onSaveDraft: { draft in
                            vm.saveDraft(draft)
                        })
                    } else {
                        RecipeBuilderView(onSave: { recipe in
                            vm.addBookmark(recipe)
                        }, onSaveDraft: { draft in
                            vm.saveDraft(draft)
                        })
                    }
                }
                
                // Toast overlay
                if let message = vm.toastMessage {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(message)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color.black.opacity(0.75))
                                .cornerRadius(12)
                            Spacer()
                        }
                        .padding(.bottom, 30)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: vm.toastMessage)
                    
                }
                
            }
        }
    }
}


#Preview {
    BookmarkView()
}
