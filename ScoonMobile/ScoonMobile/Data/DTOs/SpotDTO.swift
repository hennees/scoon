import Foundation

/// Codable mirror of the Supabase spots_with_favorites view.
/// Properties use camelCase to match JSONDecoder's .convertFromSnakeCase strategy,
/// which converts JSON keys like "image_url" → "imageUrl" before matching.
struct SpotDTO: Codable {
    let id:          String
    let name:        String
    let location:    String
    let rating:      Double
    let imageUrl:    String
    let isFavorite:  Bool
    let description: String
    let viewCount:   Int
    let likeCount:   Int
    let saveCount:   Int
    let distance:    String?
    let category:    String
    let latitude:    Double?
    let longitude:   Double?
}
