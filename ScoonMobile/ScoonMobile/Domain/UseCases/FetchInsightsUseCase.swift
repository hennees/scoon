import Foundation

struct FetchInsightsUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    /// Returns aggregated stats + top-performing spots sorted by views.
    func execute(userID: UUID) async throws -> (summary: InsightsSummary, topSpots: [Spot]) {
        let spots = try await repository.fetchExploredSpots(userID: userID)

        guard !spots.isEmpty else {
            return (InsightsSummary(totalViews: 0, avgViewsPerSpot: 0, avgLikesPerSpot: 0, avgSavesPerSpot: 0), [])
        }

        let totalViews = spots.reduce(0) { $0 + $1.viewCount }
        let avgViews   = totalViews / spots.count
        let avgLikes   = spots.reduce(0) { $0 + $1.likeCount } / spots.count
        let avgSaves   = spots.reduce(0) { $0 + $1.saveCount } / spots.count

        let summary  = InsightsSummary(totalViews: totalViews, avgViewsPerSpot: avgViews, avgLikesPerSpot: avgLikes, avgSavesPerSpot: avgSaves)
        let topSpots = spots.sorted { $0.viewCount > $1.viewCount }

        return (summary, topSpots)
    }
}
