import Foundation

@Observable
final class HomeViewModel {
    private(set) var spots:     [Spot] = []
    private(set) var isLoading: Bool   = false
    private(set) var error:     String?

    var searchText:   String    = ""
    var activeFilter: SpotFilter = .topRated

    private let fetchSpots: FetchSpotsUseCase

    init(fetchSpots: FetchSpotsUseCase) {
        self.fetchSpots = fetchSpots
    }

    var filteredSpots: [Spot] {
        guard !searchText.isEmpty else { return spots }
        return spots.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
    }

    func onAppear() async {
        guard spots.isEmpty else { return }
        await load()
    }

    func applyFilter(_ filter: SpotFilter) {
        activeFilter = filter
        Task { await load() }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            spots = try await fetchSpots.execute(filter: activeFilter)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
