import SwiftUI

/// Reusable filter panel used by Library and Bookmarks views.
struct FilterPanel: View {
    @Binding var maxIngredients: Int
    @Binding var minTime: Int
    @Binding var maxTime: Int
    @Binding var difficulty: Difficulty
    @Binding var category: Category

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Max ingredients: \(maxIngredients)")
                Spacer()
                Stepper("", value: $maxIngredients, in: 1...50)
                    .labelsHidden()
            }

            HStack {
                Text("Time: \(minTime)–\(maxTime) min")
                Spacer()
                Stepper("Min", value: $minTime, in: 0...maxTime)
                Stepper("Max", value: $maxTime, in: minTime...240)
            }

            HStack {
                Text("Difficulty")
                Spacer()
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(Difficulty.allCases) { d in
                        Text(d.rawValue).tag(d)
                    }
                }
                .pickerStyle(.menu)
            }

            HStack {
                Text("Category")
                Spacer()
                Picker("Category", selection: $category) {
                    ForEach(Category.allCases) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground)))
    }
}

#Preview {
    StatefulPreviewWrapper((10, 0, 60, Difficulty.any, Category.all)) { values in
        FilterPanel(maxIngredients: .constant(values.0), minTime: .constant(values.1), maxTime: .constant(values.2), difficulty: .constant(values.3), category: .constant(values.4))
            .padding()
    }
}

// Helper for previewing bindings
struct StatefulPreviewWrapper<Value, Content: View>: View {
    let value: Value
    let content: (Value) -> Content
    init(_ value: Value, content: @escaping (Value) -> Content) {
        self.value = value
        self.content = content
    }
    var body: some View { content(value) }
}
