import Foundation

enum SpotSortOrder: String, CaseIterable {
    case newest = "Neueste"
    case oldest = "Älteste"
    case rating = "Bewertung"
    case name   = "Name A–Z"
}

@Observable
@MainActor
final class FavoritesViewModel {
    private(set) var favorites: [Spot] = []
    private(set) var mySpots:   [Spot] = []
    private(set) var isLoading: Bool   = false
    private(set) var error:     String?

    var sortOrder: SpotSortOrder = .newest

    private let fetchFavorites: FetchFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(fetchFavorites: FetchFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.fetchFavorites = fetchFavorites
        self.toggleFavorite = toggleFavorite
    }

    var sortedFavorites: [Spot] { sorted(favorites) }
    var sortedMySpots:   [Spot] { sorted(mySpots) }

    func onAppear() async {
        guard favorites.isEmpty else { return }
        await load()
    }

    func toggle(spot: Spot) {
        Task {
            do {
                try await toggleFavorite.execute(spotID: spot.id)
                await load()
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func refresh() async {
        await load()
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            favorites = try await fetchFavorites.execute()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func sorted(_ spots: [Spot]) -> [Spot] {
        switch sortOrder {
        case .newest: return spots
        case .oldest: return spots.reversed()
        case .rating: return spots.sorted { $0.rating > $1.rating }
        case .name:   return spots.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
    }
}
