import Foundation
import MapKit

@Observable
@MainActor
final class MapViewModel {
    private(set) var spots:     [Spot]  = []
    private(set) var isLoading: Bool    = false
    private(set) var error:     String? = nil

    private let fetchSpots: FetchSpotsUseCase

    init(fetchSpots: FetchSpotsUseCase) {
        self.fetchSpots = fetchSpots
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error     = nil
        do {
            spots = try await fetchSpots.execute(filter: nil)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    // Search & filter state (driven by KartenansichtScreen)
    var searchText:       String        = ""
    var selectedCategory: SpotCategory? = nil

    /// All spots with valid GPS coordinates.
    var mappableSpots: [Spot] {
        spots.filter { $0.latitude != nil && $0.longitude != nil }
    }

    /// Mappable spots filtered by current searchText + selectedCategory.
    var filteredMappableSpots: [Spot] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        var result = mappableSpots
        if !q.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(q) || $0.location.lowercased().contains(q)
            }
        }
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        return result
    }
}
