import Foundation

@Observable
final class AddSpotViewModel {
    var name:        String = ""
    var location:    String = ""
    var description: String = ""
    var category:    SpotCategory = .nature

    private(set) var isLoading:  Bool    = false
    private(set) var error:      String? = nil
    private(set) var isSuccess:  Bool    = false
    private(set) var createdSpot: Spot?  = nil

    private let createSpot: CreateSpotUseCase

    init(createSpot: CreateSpotUseCase) {
        self.createSpot = createSpot
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
            let draft = SpotDraft(
                name:        name.trimmingCharacters(in: .whitespaces),
                location:    location.trimmingCharacters(in: .whitespaces),
                description: description.trimmingCharacters(in: .whitespaces),
                category:    category,
                imageURLs:   []
            )
            createdSpot = try await createSpot.execute(draft)
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func clearError() { error = nil }
}
