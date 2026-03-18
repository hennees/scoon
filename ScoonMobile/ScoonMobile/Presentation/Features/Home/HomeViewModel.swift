import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var spots:     [Spot] = []
    private(set) var isLoading: Bool   = false
    private(set) var error:     String?

    var searchText:   String    = ""
    var activeFilter: SpotFilter = .topRated

    private let fetchSpots: FetchSpotsUseCase
    private var loadTask: Task<Void, Never>?

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
        startObservingSpotCreated()
        guard spots.isEmpty else { return }
        await load(for: activeFilter)
    }

    private func startObservingSpotCreated() {
        guard loadTask == nil else { return }
        loadTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .spotCreated) {
                guard let self else { break }
                self.spots = []
                await self.load(for: self.activeFilter)
            }
        }
    }

    func refresh() async {
        await load(for: activeFilter)
    }

    func applyFilter(_ filter: SpotFilter) {
        activeFilter = filter
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.load(for: filter)
        }
    }

    private func load(for filter: SpotFilter) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let result = try await fetchSpots.execute(filter: filter)

            guard !Task.isCancelled else { return }
            guard filter == activeFilter else { return }

            spots = result
        } catch is CancellationError {
            return
        } catch {
            self.error = error.localizedDescription
        }
    }
}
