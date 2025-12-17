//
//  RecipeDetailView.swift
//  MixFruits
//
//  Created by GitHub Copilot on 04.12.25.
//

import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe
    @State private var isCooking: Bool = false

    var body: some View {
        ZStack {
            Design.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let name = recipe.imageName {
                        // Try loading an image saved in the app documents first, otherwise treat as SF Symbol / asset name
                        if let ui = ImageFileStorage.loadImage(named: name) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .background(Color(UIColor.secondarySystemBackground))
                        } else {
                            Image(systemName: name)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.secondarySystemBackground))
                        }
                    }

                    Text(recipe.title)
                        .font(.title)
                        .bold()

                    Text(recipe.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        Label("\(recipe.minutes) min", systemImage: "clock")
                        Label("\(recipe.steps) steps", systemImage: "list.number")
                        Spacer()
                        // Category
                        HStack(spacing: 6) {
                            Image(systemName: "tag")
                                .foregroundColor(.secondary)
                            Text(recipe.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        // Difficulty
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.secondary)
                            Text(recipe.difficulty.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Start cooking CTA
                    Button(action: { isCooking = true }) {
                        Text("Start Cooking")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical)

                    Divider()

                    // Stages preview: horizontal scrollable cards for quick overview
                    if !recipe.stages.isEmpty {
                        Text("Preview")
                            .font(.headline)
                            .padding(.top)

                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(spacing: 16) {
                                ForEach(recipe.stages.indices, id: \.self) { idx in
                                    let s = recipe.stages[idx]
                                    VStack(alignment: .leading, spacing: 8) {
                                        if let img = s.imageName, let ui = ImageFileStorage.loadImage(named: img) {
                                            Image(uiImage: ui)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 220, height: 120)
                                                .clipped()
                                                .cornerRadius(8)
                                        } else {
                                            Rectangle()
                                                .fill(Color(UIColor.secondarySystemBackground))
                                                .frame(width: 220, height: 120)
                                                .overlay(Image(systemName: "photo").foregroundColor(.secondary))
                                                .cornerRadius(8)
                                        }

                                        Text(s.title)
                                            .font(.headline)
                                            .lineLimit(1)

                                        Text(s.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)

                                        HStack(spacing: 8) {
                                            if s.timerEnabled {
                                                Image(systemName: "timer")
                                                    .foregroundColor(.secondary)
                                                Text("\(s.timerMinutes) min")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)).shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2))
                                    .frame(width: 240, height: 260, alignment: .top)
                                }
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 6)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isCooking) {
            CookingView(recipe: recipe)
        }
    }
}

#Preview {
    RecipeDetailView(recipe: Recipe(title: "Chocolate Cake", subtitle: "Rich & moist", steps: 12, minutes: 45, rating: 4, isBookmarked: false, imageName: "birthday.cake", ingredientsCount: 8, difficulty: .medium, category: .baking, stages: [
        Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
        Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
        Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
        Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
    ]))
}
