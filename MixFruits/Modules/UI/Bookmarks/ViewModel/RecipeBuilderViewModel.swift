//
//  RecipeBuilderViewModel.swift
//  MixFruits
//
//  Created by GitHub Copilot on 04.12.25.
//

import Foundation
import SwiftUI
internal import Combine

class RecipeBuilderViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var stages: [Stage] = [Stage(title: "Main")]
    @Published var mainImageName: String? = nil
    @Published var difficulty: Difficulty = .medium
    @Published var category: Category = .other
    private var cancellables = Set<AnyCancellable>()

    // Assign picked UIImage to either main image (index == -1) or a stage (index >= 0).
    func assignPickedImage(_ image: UIImage, forStage index: Int?) {
        // Save image to disk and update the corresponding model field.
        DispatchQueue.global(qos: .userInitiated).async {
            if let fileName = ImageFileStorage.saveImage(image) {
                DispatchQueue.main.async {
                    if let idx = index {
                        if idx == -1 {
                            // remove previous main image file if different
                            if let previous = self.mainImageName, previous != fileName {
                                ImageFileStorage.deleteImage(named: previous)
                            }
                            self.mainImageName = fileName
                        } else if self.stages.indices.contains(idx) {
                            // remove previous stage image if different
                            let previous = self.stages[idx].imageName
                            if let previous = previous, previous != fileName {
                                ImageFileStorage.deleteImage(named: previous)
                            }
                            self.stages[idx].imageName = fileName
                        }
                    } else {
                        // default to main image
                        if let previous = self.mainImageName, previous != fileName {
                            ImageFileStorage.deleteImage(named: previous)
                        }
                        self.mainImageName = fileName
                    }
                }
            }
        }
    }

    // Remove image for main or specific stage and delete file from disk.
    func removeImage(forStage index: Int?) {
        if let idx = index {
            if idx == -1 {
                if let prev = mainImageName {
                    ImageFileStorage.deleteImage(named: prev)
                    mainImageName = nil
                }
            } else if stages.indices.contains(idx) {
                if let prev = stages[idx].imageName {
                    ImageFileStorage.deleteImage(named: prev)
                    stages[idx].imageName = nil
                }
            }
        } else {
            if let prev = mainImageName {
                ImageFileStorage.deleteImage(named: prev)
                mainImageName = nil
            }
        }
    }

    func addStage() {
        stages.append(Stage(title: "Step \(stages.count + 1)"))
    }

    func removeStage(at offsets: IndexSet) {
        stages.remove(atOffsets: offsets)
        if stages.isEmpty { stages = [Stage(title: "Main")] }
    }

    func buildRecipe() -> Recipe {
        let steps = stages.count
        let minutes = stages.reduce(0) { $0 + ($1.timerEnabled ? $1.timerMinutes : 0) }
        // Prefer explicit main image if set, otherwise fall back to first stage image if available
        let imageName = mainImageName ?? stages.first { $0.imageName != nil }?.imageName
        return Recipe(title: title.isEmpty ? "Untitled" : title,
                  subtitle: subtitle,
                  steps: steps,
                  minutes: minutes,
                  rating: 0,
                  isBookmarked: true,
                  imageName: imageName,
                  ingredientsCount: stages.count,
                  difficulty: difficulty,
                      category: category,
                      stages: [
                          Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                          Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
                          Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 40),
                          Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: nil, timerEnabled: true, timerMinutes: 10)
                      ])
    }

    func buildDraft() -> RecipeDraft {
        var draft = RecipeDraft(title: title.isEmpty ? "Untitled draft" : title, subtitle: subtitle, stages: stages)
        draft.mainImageName = mainImageName
        return draft
    }
}
