import Foundation

/// Service responsible for persisting and loading `RecipeDraft` objects to disk.
/// Stores drafts as JSON in the app's Documents directory (file name: `drafts.json`).
final class DraftStore {
    private let fileName: String
    private let queue = DispatchQueue(label: "mixfruits.draftstore", qos: .userInitiated)

    init(fileName: String = "drafts.json") {
        self.fileName = fileName
    }

    private func fileURL() throws -> URL {
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return docs.appendingPathComponent(fileName)
    }

    func load() throws -> [RecipeDraft] {
        let url = try fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([RecipeDraft].self, from: data)
    }

    func save(_ drafts: [RecipeDraft]) throws {
        let url = try fileURL()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(drafts)
        try data.write(to: url, options: [.atomic])
    }

    func deleteStore() throws {
        let url = try fileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
