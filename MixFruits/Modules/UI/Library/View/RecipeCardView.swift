//
//  RecipeCardView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 28.11.25.
//

import SwiftUI

struct RecipeCardView: View {
    var recipe: Recipe
    @State private var isBookmarkedState: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Image
            ZStack {
                if let name = recipe.imageName {
                    RemoteImageView(name: name, placeholder: Image(systemName: name), contentMode: .fill, height: 96)
                        .frame(width: 96)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 96, height: 96)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
            )

            // Main content
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(recipe.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Bookmark button
                    Button {
                        withAnimation(.easeInOut) {
                            isBookmarkedState.toggle()
                        }
                    } label: {
                        Image(systemName: isBookmarkedState ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isBookmarkedState ? .accentColor : .gray)
                            .imageScale(.large)
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                }

                // Info chips placed inside a horizontally scrolling container for iOS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        InfoChip(systemImage: "clock", text: "\(recipe.minutes) min")
                        InfoChip(systemImage: "list.number", text: "\(recipe.steps) steps")
                        InfoChip(systemImage: "flame", text: "Medium")
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: InfoChip.chipSize.height + 12)

                // Rating
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= recipe.rating ? "star.fill" : "star")
                            .foregroundColor(index <= recipe.rating ? Color.yellow : Color.gray.opacity(0.6))
                            .imageScale(.small)
                    }

                    Spacer()
                }
            }

        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Design.cardBackground.opacity(0.2))
                .overlay(Design.cardGradient.opacity(0.12).cornerRadius(14))
        )
        .overlay(
            // Subtle top-to-bottom stroke to increase legibility over colorful background
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.black.opacity(0.06)]), startPoint: .top, endPoint: .bottom),
                    lineWidth: 1
                )
        )
        // Shadow focused below the card for clearer separation from background
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 6)
        .padding(.horizontal)
    }

    // Small reusable chip view used in the card
    struct InfoChip: View {
        var systemImage: String
        var text: String

        // Fixed size for chips so they all share identical width and height on iOS.
        // Adjust `chipSize` to change overall dimensions.
        static let chipSize: CGSize = CGSize(width: 96, height: 34)

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .imageScale(.small)
                Text(text)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
                .frame(width: Self.chipSize.width, height: Self.chipSize.height)
            .background(
                RoundedRectangle(cornerRadius: Self.chipSize.height / 2)
                    .fill(Design.chipGradient)
                    .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
            )
            .foregroundColor(.primary)
        }
    }
}

#Preview {
    RecipeCardView(recipe: Recipe(title: "Chocolate Cake", subtitle: "Rich & moist", steps: 12, minutes: 45, rating: 4, isBookmarked: false, imageName: "birthday.cake", ingredientsCount: 8, difficulty: .medium, category: .baking, stages: [
        Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
        Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
        Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
        Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
    ]))
}
