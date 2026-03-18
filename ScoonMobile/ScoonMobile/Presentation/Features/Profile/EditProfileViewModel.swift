import Foundation
import UIKit

extension Notification.Name {
    static let profileUpdated = Notification.Name("scoon.profileUpdated")
}

@Observable
@MainActor
final class EditProfileViewModel {
    var username: String
    var bio:      String
    var selectedAvatar: UIImage?

    private(set) var isLoading = false
    private(set) var isSuccess = false
    private(set) var error: String?

    private let user:          User
    private let updateProfile: UpdateProfileUseCase
    private let uploadService: ImageUploadService?

    init(user: User, updateProfile: UpdateProfileUseCase, uploadService: ImageUploadService? = nil) {
        self.user          = user
        self.username      = user.username
        self.bio           = user.bio
        self.updateProfile = updateProfile
        self.uploadService = uploadService
    }

    var hasChanges: Bool {
        username.trimmingCharacters(in: .whitespaces) != user.username ||
        bio.trimmingCharacters(in: .whitespaces)      != user.bio      ||
        selectedAvatar != nil
    }

    func submit() async {
        guard hasChanges, !isLoading else { return }
        isLoading = true
        error = nil
        do {
            var newAvatarURL: String? = nil
            if let image = selectedAvatar, let uploadService {
                newAvatarURL = try await uploadService.upload(image)
            }
            let updated = try await updateProfile.execute(
                userID:    user.id,
                username:  username,
                bio:       bio,
                avatarURL: newAvatarURL
            )
            NotificationCenter.default.post(name: .profileUpdated, object: updated)
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func clearError() { error = nil }
}
