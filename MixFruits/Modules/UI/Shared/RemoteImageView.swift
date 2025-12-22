import SwiftUI
import UIKit

/// SwiftUI view that shows an image from local cache (ImageFileStorage) or fetches from Supabase Storage.
struct RemoteImageView: View {
    let name: String?
    let placeholder: Image
    let contentMode: ContentMode
    let height: CGFloat?
    let width: CGFloat?

    @State private var uiImage: UIImage? = nil
    @State private var isLoading = false

    init(name: String?, placeholder: Image = Image(systemName: "photo"), contentMode: ContentMode = .fill, height: CGFloat? = nil, width: CGFloat? = nil) {
        self.name = name
        self.placeholder = placeholder
        self.contentMode = contentMode
        self.height = height
        self.width = width
    }

    var body: some View {
        Group {
            if let ui = uiImage {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                ZStack {
                    Rectangle().fill(Color(UIColor.secondarySystemBackground))
                    ProgressView()
                }
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .task(id: name) {
            await loadIfNeeded()
        }
    }

    private func loadIfNeeded() async {
        guard let name = name, !name.isEmpty else { return }
        // Try local cache first
        if let local = ImageFileStorage.loadImage(named: name) {
            uiImage = local
            return
        }

        // Otherwise fetch from Supabase
        isLoading = true
        defer { isLoading = false }

        if let fetched = await SupabaseStorage.fetchImage(named: name) {
            uiImage = fetched
        }
    }
}
