import Foundation

/// Codable mirror of the future API response for a spot.
/// Field names match a typical REST/JSON API (snake_case).
struct SpotDTO: Codable {
    let id:          String
    let name:        String
    let location:    String
    let rating:      Double
    let image_url:   String
    let is_favorite: Bool
    let description: String
    let view_count:  Int
    let like_count:  Int
    let save_count:  Int
    let distance:    String?
    let category:    String
}
