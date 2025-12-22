import Foundation

/// Service responsible for persisting and loading `Recipe` objects to disk.
///
/// Stores recipes as JSON in the app's Documents directory (default file name: `recipes.json`).
final class RecipeStore {
    private let fileName: String
    private let queue = DispatchQueue(label: "mixfruits.recipestore", qos: .userInitiated)

    /// Create a store using the specified JSON file name (in Documents directory).
    init(fileName: String = "recipes.json") {
        self.fileName = fileName
    }

    private func fileURL() throws -> URL {
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return docs.appendingPathComponent(fileName)
    }

    /// Load recipes synchronously from storage.
    /// - Throws: any file I/O or decoding error.
    /// - Returns: an array of `Recipe` loaded from disk (may be empty).
    func load() throws -> [Recipe] {
        // Always load recipes from the bundled sample JSON resource.
        // This ensures the app uses the packaged sample data regardless of persisted files.
        if let bundleURL = Bundle.main.url(forResource: "sample_recipes", withExtension: "json") {
            let data = try Data(contentsOf: bundleURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Recipe].self, from: data)
        }

        // If the bundled sample is not found, return an empty array.
        return []
    }

    /// Load only the persisted recipes file from Documents (do not read bundled samples).
    /// - Throws: any file I/O or decoding error.
    /// - Returns: an array of `Recipe` loaded from the persisted file (may be empty).
    func loadPersisted() throws -> [Recipe] {
        let url = try fileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Recipe].self, from: data)
        }
        return []
    }

    /// Load recipes asynchronously (executes on a background queue).
    func loadAsync() async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    let recipes = try self.load()
                    cont.resume(returning: recipes)
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    /// Save recipes to storage (overwrites existing file).
    /// - Throws: any file I/O or encoding error.
    func save(_ recipes: [Recipe]) throws {
        let url = try fileURL()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(recipes)
        try data.write(to: url, options: [.atomic])
    }

    /// Remove the persisted recipes file.
    func deleteStore() throws {
        let url = try fileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Example usage

/*
let store = RecipeStore()

// Load
do {
    let recipes = try store.load()
    // use recipes or fall back to sample data
} catch {
    print("Failed to load recipes:", error)
}

// Save
do {
    try store.save(myRecipes)
} catch {
    print("Failed to save recipes:", error)
}

// Async load
Task {
    do {
        let recipes = try await store.loadAsync()
    } catch {
        print(error)
    }
}
*/
