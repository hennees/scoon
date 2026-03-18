import Foundation
import MapKit

@Observable
@MainActor
final class MapViewModel {
    private(set) var spots:     [Spot]  = []
    private(set) var isLoading: Bool    = false
    private(set) var error:     String? = nil

    private var viewportRegion: MKCoordinateRegion?
    private var lastNearbyCenter: CLLocationCoordinate2D?
    private var lastNearbyRadius: Double?

    private let fetchSpots: FetchSpotsUseCase
    private let fetchNearbySpots: FetchNearbySpotsUseCase

    init(fetchSpots: FetchSpotsUseCase, fetchNearbySpots: FetchNearbySpotsUseCase) {
        self.fetchSpots = fetchSpots
        self.fetchNearbySpots = fetchNearbySpots
    }

    func load(force: Bool = false) async {
        guard !isLoading else { return }
        if !force, !shouldRefetchNearby() { return }

        isLoading = true
        error = nil
        do {
            if let center = viewportRegion?.center {
                let radius = effectiveRadius
                spots = try await fetchNearbySpots.execute(
                    latitude: center.latitude,
                    longitude: center.longitude,
                    radiusMeters: radius
                )
                lastNearbyCenter = center
                lastNearbyRadius = radius
            } else {
                spots = try await fetchSpots.execute(filter: nil)
            }
        } catch {
            // Graceful fallback to broad query if nearby RPC is unavailable.
            do {
                spots = try await fetchSpots.execute(filter: nil)
            } catch {
                self.error = error.localizedDescription
            }
        }
        isLoading = false
    }

    private func shouldRefetchNearby() -> Bool {
        guard let current = viewportRegion?.center else { return true }
        guard let previous = lastNearbyCenter, let previousRadius = lastNearbyRadius else { return true }

        let movedMeters = CLLocation(latitude: current.latitude, longitude: current.longitude)
            .distance(from: CLLocation(latitude: previous.latitude, longitude: previous.longitude))
        let radiusDelta = abs(effectiveRadius - previousRadius)

        return movedMeters > 280 || radiusDelta > 450
    }

    // Search & filter state (driven by KartenansichtScreen)
    var searchText:       String        = ""
    var selectedCategory: SpotCategory? = nil

    func updateViewport(region: MKCoordinateRegion) {
        viewportRegion = region
    }

    private var effectiveRadius: Double {
        guard let region = viewportRegion else { return 2500 }
        let approxMetersPerLatDegree = 111_132.0
        let meters = max(region.span.latitudeDelta * approxMetersPerLatDegree, 800)
        return min(meters * 0.75, 12000)
    }

    /// All spots with valid GPS coordinates.
    var mappableSpots: [Spot] {
        spots.filter { $0.latitude != nil && $0.longitude != nil }
    }

    var categoryCounts: [SpotCategory: Int] {
        Dictionary(grouping: mappableSpots, by: { $0.category }).mapValues { $0.count }
    }

    /// Mappable spots filtered by current searchText + selectedCategory.
    var filteredMappableSpots: [Spot] {
        let q = normalizedQuery
        var result = mappableSpots
        if !q.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(q) || $0.location.lowercased().contains(q)
            }
        }
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        return sortByDistanceIfPossible(result)
    }

    var visibleFilteredSpots: [Spot] {
        guard let region = viewportRegion else { return filteredMappableSpots }
        let latDelta = region.span.latitudeDelta * 0.75
        let lonDelta = region.span.longitudeDelta * 0.75
        let center = region.center

        let visible = filteredMappableSpots.filter { spot in
            guard let lat = spot.latitude, let lon = spot.longitude else { return false }
            return abs(lat - center.latitude) <= latDelta && abs(lon - center.longitude) <= lonDelta
        }
        return visible.isEmpty ? filteredMappableSpots : visible
    }

    private var normalizedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func sortByDistanceIfPossible(_ items: [Spot]) -> [Spot] {
        guard let center = viewportRegion?.center else { return items }
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return items.sorted { lhs, rhs in
            let lhsDistance = distance(from: centerLocation, to: lhs)
            let rhsDistance = distance(from: centerLocation, to: rhs)
            return lhsDistance < rhsDistance
        }
    }

    private func distance(from center: CLLocation, to spot: Spot) -> CLLocationDistance {
        guard let lat = spot.latitude, let lon = spot.longitude else {
            return .greatestFiniteMagnitude
        }
        return center.distance(from: CLLocation(latitude: lat, longitude: lon))
    }
}
