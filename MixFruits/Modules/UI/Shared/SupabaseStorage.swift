import Foundation
import UIKit

/// Minimal Supabase Storage helper.
/// Configure `projectUrl` and `bucket` for your Supabase project.
enum SupabaseStorage {
    // TODO: Replace with your Supabase project URL (e.g. "https://xyzabcpqrs.supabase.co")
    static let projectUrl = "https://jmoepondymkxufmcgdzm.supabase.co"
    // TODO: Replace with the bucket name where images are stored (public bucket recommended)
    static let bucket = "recipe-images"

    /// Construct a public object URL for a stored file name.
    static func url(for filename: String) -> URL? {
        guard !projectUrl.isEmpty, !bucket.isEmpty else { return nil }
        // Supabase public storage URL pattern
        // https://{project}.supabase.co/storage/v1/object/public/{bucket}/{path}
        let path = filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
        let urlString = "\(projectUrl)/storage/v1/object/public/\(bucket)/\(path)"
        return URL(string: urlString)
    }

    /// Fetch an image from Supabase and save to local documents via ImageFileStorage.
    /// Returns a UIImage on success or nil on error.
    static func fetchImage(named filename: String) async -> UIImage? {
        // If already present in local cache, return it
        if let ui = ImageFileStorage.loadImage(named: filename) {
            return ui
        }

        guard let url = url(for: filename) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                // Save to local cache for future loads
                ImageFileStorage.saveImage(image, as: filename)
                return image
            }
        } catch {
            print("SupabaseStorage.fetchImage error:", error)
        }
        return nil
    }
}
