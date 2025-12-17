//
//  Recipe.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 4.12.25.
//

import Foundation
// Simple local model for preview and quick iterations
enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case any = "Any"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }
}

enum Category: String, CaseIterable, Identifiable, Codable {
    case all = "All"
    case baking = "Baking"
    case smoothie = "Smoothie"
    case sweets = "Sweets"
    case hot = "Hot"
    case hotDessert = "Hot Dessert"
    case frozenDessert = "Frozen Dessert"
    case salad = "Salad"
    case dessert = "Dessert"
    case other = "Other"

    var id: String { rawValue }
}

struct Recipe: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var subtitle: String
    var steps: Int
    var minutes: Int
    var rating: Int // 0..5
    var isBookmarked: Bool
    var imageName: String? // SF Symbol or asset name
    
    // Extended fields for filtering + UI
    var ingredientsCount: Int = 0
    var difficulty: Difficulty = .medium
    var category: Category = .other
        
    var stages: [Stage]
}
