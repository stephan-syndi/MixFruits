import SwiftUI
import PhotosUI

// A simple PHPicker wrapper that returns a UIImage via a completion handler.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator

        // Embed in navigation controller so we can show a close button
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .pageSheet
        // add a close button
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // If results are empty, user probably cancelled; do not auto-dismiss here —
            // allow the close button or swipe to dismiss to control the sheet.
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let err = error {
                    print("ImagePicker: error loading image:", err)
                }
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.onImagePicked(image)
                        self.parent.isPresented = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.parent.isPresented = false
                    }
                }
            }
        }
    }
}

// Helpers to save/load images to the app's Documents directory.
enum ImageFileStorage {
    static func documentsDirectory() -> URL? {
        try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    @discardableResult
    static func saveImage(_ image: UIImage, as filename: String? = nil) -> String? {
        guard let docs = documentsDirectory() else { return nil }
        let id = filename ?? UUID().uuidString + ".jpg"
        let url = docs.appendingPathComponent(id)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return id
        } catch {
            print("ImageFileStorage.saveImage error:", error)
            return nil
        }
    }

    static func loadImage(named filename: String) -> UIImage? {
        guard let docs = documentsDirectory() else { return nil }
        let url = docs.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }

    static func deleteImage(named filename: String) {
        guard let docs = documentsDirectory() else { return }
        let url = docs.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("ImageFileStorage.deleteImage error:", error)
            }
        }
    }

    static func listSavedImages() -> [String] {
        guard let docs = documentsDirectory() else { return [] }
        do {
            let items = try FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
            return items.map { $0.lastPathComponent }.filter { $0.lowercased().hasSuffix(".jpg") || $0.lowercased().hasSuffix(".png") }
        } catch {
            print("ImageFileStorage.listSavedImages error:", error)
            return []
        }
    }
}
