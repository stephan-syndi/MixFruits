//
//  Stage.swift
//  MixFruits
//
//  Created by GitHub Copilot on 04.12.25.
//

import Foundation

struct Stage: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var title: String = "Main"
    var description: String = ""
    var imageName: String? = nil
    var timerEnabled: Bool = false
    var timerMinutes: Int = 0
}

struct RecipeDraft: Identifiable, Codable {
    var id = UUID()
    var title: String
    var subtitle: String
    var stages: [Stage]
    var mainImageName: String? = nil
} 
