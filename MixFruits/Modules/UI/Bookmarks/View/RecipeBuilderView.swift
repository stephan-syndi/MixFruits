//
//  RecipeBuilderView.swift
//  MixFruits
//
//  Created by GitHub Copilot on 04.12.25.
//

import SwiftUI
import PhotosUI

struct RecipeBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: RecipeBuilderViewModel
    var onSave: ((Recipe) -> Void)? = nil
    var onSaveDraft: ((RecipeDraft) -> Void)? = nil
    /// Optional callback to notify callers that an existing draft was removed after saving
    var onRemoveDraft: ((RecipeDraft) -> Void)? = nil
    private let originalDraft: RecipeDraft?
    @State private var showingPickerForStage: Int? = nil
    
    private func presentImagePicker(forStage idx: Int) {
        showingPickerForStage = idx
        // Slight delay to avoid presentation conflicts from SwiftUI transitions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            NativeImagePicker.present { image in
                if let img = image {
                    vm.assignPickedImage(img, forStage: idx)
                }
            }
        }
    }
    
    init(
        vm: RecipeBuilderViewModel? = nil,
        draft: RecipeDraft? = nil,
        onSave: ((Recipe) -> Void)? = nil,
        onSaveDraft: ((RecipeDraft) -> Void)? = nil,
        onRemoveDraft: ((RecipeDraft) -> Void)? = nil) {
        if let provided = vm {
            _vm = StateObject(wrappedValue: provided)
                self.originalDraft = draft
            } else if let draft = draft {
            let viewModel = RecipeBuilderViewModel()
            viewModel.title = draft.title
            viewModel.subtitle = draft.subtitle
            viewModel.stages = draft.stages
            viewModel.mainImageName = draft.mainImageName
            _vm = StateObject(wrappedValue: viewModel)
            self.originalDraft = draft
        } else {
            _vm = StateObject(wrappedValue: RecipeBuilderViewModel())
            self.originalDraft = nil
        }
        self.onSave = onSave
        self.onSaveDraft = onSaveDraft
        self.onRemoveDraft = onRemoveDraft
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Main") {
                    HStack(spacing: 12) {
                        Group {
                            
                            Button(action: {
                                // use -1 as marker for main image
                                presentImagePicker(forStage: -1)
                            }) {
                                
                                if let mainImageName = vm.mainImageName,
                                   let ui = ImageFileStorage.loadImage(named: mainImageName) {
                                    Image(uiImage: ui)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(width: 72, height: 72)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemBackground)))
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Title", text: $vm.title)
                            TextField("Subtitle", text: $vm.subtitle)
                            HStack {
                                Picker("Difficulty", selection: $vm.difficulty) {
                                    ForEach(Difficulty.allCases) { d in
                                        Text(d.rawValue).tag(d)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            Picker("Category", selection: $vm.category) {
                                ForEach(Category.allCases) { c in
                                    Text(c.rawValue).tag(c)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Spacer()
                    }
                }
                
                Section("Stages") {
                    ForEach(vm.stages.indices, id: \.self) { idx in
                        StageCardView(stage: $vm.stages[idx], onSelectImage: {
                            presentImagePicker(forStage: idx)
                        })
                        .padding(.vertical, 6)
                    }
                    .onDelete { idx in vm.removeStage(at: idx) }
                    
                    Button(action: vm.addStage) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add stage")
                        }
                    }
                }
            }
            .navigationTitle("Recipe Builder")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let recipe = vm.buildRecipe()
                        onSave?(recipe)

                        // If this view was opened from an existing draft, remove it from persistent drafts storage
                        if let draft = originalDraft {
                            DispatchQueue.global(qos: .utility).async {
                                do {
                                    let store = DraftStore()
                                    var existing = try store.load()
                                    existing.removeAll { $0.id == draft.id }
                                    try store.save(existing)
                                    DispatchQueue.main.async {
                                        // notify caller (e.g. BookmarkViewModel) to update in-memory drafts list
                                        onRemoveDraft?(draft)
                                    }
                                } catch {
                                    print("Failed to remove saved draft:", error)
                                }
                            }
                        }

                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Save Draft") {
                        let draft = vm.buildDraft()
                        onSaveDraft?(draft)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecipeBuilderView()
}
