//
//  HomeView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

/*
 Логотип приложения
 Статистика: количество добавленных в “избранное” к к-во приготовленных мною.
 Последний прочитанный рецепт и краткая сводка о нем: название, количество шагов, время на готовку, популярность, статус (в закладках/нет), сложность.
 Клик по нему открывает полное описание рецепта.
 */

import SwiftUI

struct HomeView: View {
    @StateObject private var stats = AppStatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Design.backgroundGradient
                    .ignoresSafeArea()

                GeometryReader { geo in
                    ScrollView {
                        VStack {
                            Spacer(minLength: 0)

                            VStack(spacing: 16) {
                            // App logo
                            Image(.logo)
                                .resizable()
                                .frame(width: 774.03/2, height: 669.23/2)
                                .foregroundStyle(Design.primary)
                                .padding(.top, 12)

                            // Statistics summary
                            HStack(spacing: 12) {
                                StatPill(label: "Bookmarks", value: String(stats.bookmarksCount), color: Design.primary)
                                StatPill(label: "Done", value: String(stats.doneRecipeCount), color: Design.accent)
                                StatPill(label: "Library", value: String(stats.recentActions.first(where: { $0.title.contains("Recipes") })?.title.components(separatedBy: ": ").last ?? "0"), color: Design.mellow)
                            }
                            .padding(.horizontal)

                            // Last viewed recipe preview
                            if let last = stats.lastRecipe {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Last viewed")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        NavigationLink(destination: RecipeDetailView(recipe: last)) {
                                            Text("Open")
                                        }
                                    }

                                    RecipeCardView(recipe: last)
                                }
                                .padding(.horizontal)
                            }

                            // Recent actions
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recent")
                                    .font(.headline)
                                ForEach(stats.recentActions) { action in
                                    HStack {
                                        Text(action.title)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(action.date, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Design.headerGradient))
                                    .shadow(color: Design.softShadow, radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal)
                        }

                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: geo.size.height)
                    }
                }
            }
        }
    }
}

struct StatPill: View {
    var label: String
    var value: String
    var color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.14)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.02)))
        .shadow(color: Design.softShadow, radius: 6, x: 0, y: 3)
    }
}

#Preview {
    HomeView()
}
