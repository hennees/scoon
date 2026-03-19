import Foundation
import UIKit

extension Notification.Name {
    static let spotCreated = Notification.Name("scoon.spotCreated")
}

@Observable
@MainActor
final class AddSpotViewModel {
    var name:           String      = ""
    var location:       String      = ""
    var description:    String      = ""
    var category:       SpotCategory = .nature
    var selectedImages: [UIImage]   = []
    var latitude:       Double?     = nil
    var longitude:      Double?     = nil

    private(set) var isLoading:   Bool    = false
    private(set) var error:       String? = nil
    private(set) var isSuccess:   Bool    = false
    private(set) var createdSpot: Spot?   = nil

    private let createSpot:    CreateSpotUseCase
    private let uploadService: ImageUploadService?

    init(createSpot: CreateSpotUseCase, uploadService: ImageUploadService? = nil) {
        self.createSpot    = createSpot
        self.uploadService = uploadService
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func submit() async {
        guard isValid else {
            error = "Bitte fülle Name, Location und Beschreibung aus."
            return
        }
        isLoading = true
        error = nil
        do {
            var imageURLs: [String] = []
            if let uploadService, !selectedImages.isEmpty {
                for image in selectedImages {
                    let url = try await uploadService.upload(image)
                    imageURLs.append(url)
                }
            }

            let draft = SpotDraft(
                name:        name.trimmingCharacters(in: .whitespaces),
                location:    location.trimmingCharacters(in: .whitespaces),
                description: description.trimmingCharacters(in: .whitespaces),
                category:    category,
                imageURLs:   imageURLs,
                latitude:    latitude,
                longitude:   longitude
            )
            createdSpot = try await createSpot.execute(draft)
            isSuccess = true
            NotificationCenter.default.post(name: .spotCreated, object: nil)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func clearError() { error = nil }
}
