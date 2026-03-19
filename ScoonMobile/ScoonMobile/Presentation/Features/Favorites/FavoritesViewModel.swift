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
    private let fetchMySpots:   FetchMySpotsUseCase

    init(fetchFavorites: FetchFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase, fetchMySpots: FetchMySpotsUseCase) {
        self.fetchFavorites = fetchFavorites
        self.toggleFavorite = toggleFavorite
        self.fetchMySpots   = fetchMySpots
    }

    var sortedFavorites: [Spot] { sorted(favorites) }
    var sortedMySpots:   [Spot] { sorted(mySpots) }

    func onAppear() async {
        guard favorites.isEmpty else { return }
        async let favoritesLoad: Void = load()
        async let mySpotsLoad:   Void = loadMySpots()
        _ = await (favoritesLoad, mySpotsLoad)
    }

    func toggle(spot: Spot) {
        flipLocally(spotID: spot.id)
        Task {
            do {
                try await toggleFavorite.execute(spotID: spot.id)
                await load()
            } catch {
                flipLocally(spotID: spot.id) // revert
                self.error = error.localizedDescription
            }
        }
    }

    private func flipLocally(spotID: UUID) {
        if let i = favorites.firstIndex(where: { $0.id == spotID }) {
            favorites[i].isFavorite.toggle()
        }
    }

    func refresh() async {
        async let favoritesLoad: Void = load()
        async let mySpotsLoad:   Void = loadMySpots()
        _ = await (favoritesLoad, mySpotsLoad)
    }

    func loadMySpots() async {
        do {
            mySpots = try await fetchMySpots.execute()
        } catch {
            self.error = error.localizedDescription
        }
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
