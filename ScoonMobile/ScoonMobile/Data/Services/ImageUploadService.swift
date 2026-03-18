import Foundation
import UIKit

enum ImageUploadError: LocalizedError {
    case compressionFailed
    case invalidURL
    case uploadFailed(Int)

    var errorDescription: String? {
        switch self {
        case .compressionFailed:    return "Bild konnte nicht komprimiert werden."
        case .invalidURL:           return "Ungültige Upload-URL."
        case .uploadFailed(let c):  return "Bild-Upload fehlgeschlagen (Status \(c))."
        }
    }
}

final class ImageUploadService {
    private let supabaseURL:  String
    private let anonKey:      String
    private let sessionStore: AuthSessionStore

    private let bucket = "spot-images"

    init(supabaseURL: String, anonKey: String, sessionStore: AuthSessionStore) {
        self.supabaseURL  = supabaseURL
        self.anonKey      = anonKey
        self.sessionStore = sessionStore
    }

    /// Uploads a UIImage to Supabase Storage and returns the public URL.
    func upload(_ image: UIImage, maxSidePoints: CGFloat = 1200) async throws -> String {
        guard let data = resize(image, maxSide: maxSidePoints).jpegData(compressionQuality: 0.82) else {
            throw ImageUploadError.compressionFailed
        }

        let filename  = "\(UUID().uuidString).jpg"
        let urlString = "\(supabaseURL)/storage/v1/object/\(bucket)/\(filename)"
        guard let url = URL(string: urlString) else { throw ImageUploadError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey,      forHTTPHeaderField: "apikey")

        if let token = await sessionStore.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await URLSession.shared.upload(for: request, from: data)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw ImageUploadError.uploadFailed(code)
        }

        return "\(supabaseURL)/storage/v1/object/public/\(bucket)/\(filename)"
    }

    // MARK: – Helpers

    private func resize(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let size = image.size
        let maxDim = max(size.width, size.height)
        guard maxDim > maxSide else { return image }
        let scale   = maxSide / maxDim
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
