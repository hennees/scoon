import Foundation

/// Canonical photo-spot entity. Replaces SpotModel, FavoriteSpot, NearbySpot
/// previously scattered across individual screen files.
struct Spot: Identifiable, Hashable {
    let id:          UUID
    let name:        String
    let location:    String
    let rating:      Double
    let imageURL:    String
    var isFavorite:  Bool
    let description: String
    let viewCount:   Int
    let likeCount:   Int
    let saveCount:   Int
    let distance:    String?   // optional – only populated in map/nearby context
    let category:    SpotCategory
}

enum SpotCategory: String, CaseIterable, Hashable {
    case nature        = "Nature"
    case urban         = "Urban"
    case architecture  = "Architecture"
    case hidden        = "Hidden"
    case parkGarden    = "Park & Garten"
    case exhibitions   = "Ausstellungen"
    case monuments     = "Denkmäler"
}

enum SpotFilter: String, CaseIterable {
    case topRated    = "Top Bewertet"
    case hiddenGems  = "Geheimtipps"
    case mostViewed  = "Meist gesehen"
    case newlyFound  = "Neu entdeckt"
}
