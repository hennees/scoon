import Foundation
import UIKit

@Observable
@MainActor
final class AddPhotoToSpotViewModel {
    let spot: Spot
    var selectedImages: [UIImage] = []

    private(set) var isLoading  = false
    private(set) var isSuccess  = false
    private(set) var error: String?

    private let spotRepository: SpotRepositoryProtocol
    private let uploadService:  ImageUploadService?

    init(spot: Spot, spotRepository: SpotRepositoryProtocol, uploadService: ImageUploadService? = nil) {
        self.spot           = spot
        self.spotRepository = spotRepository
        self.uploadService  = uploadService
    }

    var canSubmit: Bool { !selectedImages.isEmpty && !isLoading }

    func submit() async {
        guard canSubmit else { return }
        isLoading = true
        error = nil
        do {
            var imageURLs: [String] = []
            if let uploadService, !selectedImages.isEmpty {
                for image in selectedImages {
                    let url = try await uploadService.upload(image)
                    imageURLs.append(url)
                }
            } else {
                // Mock fallback: use placeholder URLs
                imageURLs = selectedImages.map { _ in spot.imageURL }
            }
            try await spotRepository.addPhotosToSpot(spotID: spot.id, imageURLs: imageURLs)
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func clearError() { error = nil }
}
