//
//  CookingView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 9.12.25.
//

import SwiftUI
internal import Combine

struct CookingView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int = 0
    @State private var isTimerRunning: Bool = false
    @State private var remainingSeconds: Int? = nil
    @State private var showTimerFinished: Bool = false
    @State private var stageTimerFinished: Bool = false
    private let tick = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if recipe.stages.indices.contains(index) {
                    let stage = recipe.stages[index]
                    Text(stage.title)
                        .font(.title2)
                        .bold()

                    Text(stage.description)
                        .foregroundColor(.secondary)
                        .padding()

                    if let img = stage.imageName, let ui = ImageFileStorage.loadImage(named: img) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                    }

                    if stage.timerEnabled {
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "timer")
                                    .foregroundColor(.secondary)
                                if let secs = remainingSeconds {
                                    Text(CookingView.formatSeconds(secs))
                                        .font(.headline)
                                } else {
                                    Text("\(stage.timerMinutes) min")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button(action: {
                                    if isTimerRunning {
                                        isTimerRunning = false
                                    } else {
                                        remainingSeconds = (remainingSeconds ?? (stage.timerMinutes * 60))
                                        isTimerRunning = true
                                        stageTimerFinished = false
                                    }
                                }) {
                                    Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 6)
                    }

                    Spacer()

                    HStack {
                        if index > 0 {
                            Button("Back") { index -= 1 }
                                .buttonStyle(.bordered)
                        }

                        Spacer()

                        // Next / Done button behavior: if stage has a timer, pressing Next/Done starts the timer
                        // and the button is disabled while the timer runs. After timer finishes, pressing moves on.
                        let isLast = index >= recipe.stages.count - 1
                        let currentHasTimer = stage.timerEnabled

                        Button(action: {
                            if currentHasTimer {
                                // If timer already finished, advance; otherwise start it
                                if stageTimerFinished {
                                    if isLast {
                                        dismiss()
                                    } else {
                                        index += 1
                                    }
                                } else {
                                    // start the timer
                                    remainingSeconds = remainingSeconds ?? (stage.timerMinutes * 60)
                                    isTimerRunning = true
                                    stageTimerFinished = false
                                }
                            } else {
                                // no timer -> normal advance
                                if isLast {
                                    dismiss()
                                } else {
                                    index += 1
                                }
                            }
                        }) {
                            Text(isLast ? (currentHasTimer && !stageTimerFinished ? (isTimerRunning ? "Running..." : "Start timer") : "Done") : (currentHasTimer && !stageTimerFinished ? (isTimerRunning ? "Running..." : "Start timer") : "Next"))
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(currentHasTimer && !stageTimerFinished && isTimerRunning)
                    }
                } else {
                    Text("No steps available")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Close") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Cooking")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(tick) { _ in
                guard isTimerRunning, let secs = remainingSeconds else { return }
                if secs > 0 {
                    remainingSeconds = secs - 1
                } else {
                    isTimerRunning = false
                    remainingSeconds = 0
                    stageTimerFinished = true
                    showTimerFinished = true
                }
            }
            .alert("Timer", isPresented: $showTimerFinished) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Step timer finished")
            }
            .onChange(of: index) { _ in
                // Reset any running timer when moving between stages
                isTimerRunning = false
                remainingSeconds = nil
                stageTimerFinished = false
            }
        }
    }

    static func formatSeconds(_ s: Int) -> String {
        let m = s / 60
        let sec = s % 60
        return String(format: "%d:%02d", m, sec)
    }
}

#Preview {
    CookingView(recipe: Recipe(title: "Chocolate Cake", subtitle: "Rich & moist", steps: 12, minutes: 45, rating: 4, isBookmarked: false, imageName: "birthday.cake", ingredientsCount: 8, difficulty: .medium, category: .baking, stages: [
        Stage(title: "Prepare filling", description: "Mix apples, sugar and spices.", imageName: nil, timerEnabled: false, timerMinutes: 0),
        Stage(title: "Roll dough", description: "Roll out the pastry and place in the pan.", imageName: nil, timerEnabled: false, timerMinutes: 0),
        Stage(title: "Bake", description: "Bake until golden.", imageName: nil, timerEnabled: true, timerMinutes: 1),
        Stage(title: "Cool & glaze", description: "Let cool then apply glaze.", imageName: "home", timerEnabled: true, timerMinutes: 1),]
                              )
    )
}
