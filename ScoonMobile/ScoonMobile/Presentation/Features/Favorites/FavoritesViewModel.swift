import Foundation

@Observable
@MainActor
final class FavoritesViewModel {
    private(set) var favorites: [Spot] = []
    private(set) var isLoading: Bool   = false
    private(set) var error:     String?

    private let fetchFavorites: FetchFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(fetchFavorites: FetchFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.fetchFavorites = fetchFavorites
        self.toggleFavorite = toggleFavorite
    }

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
}
