import Foundation

/// Codable mirror of the Supabase spots_with_favorites view.
/// Field names match snake_case columns; JSONDecoder uses .convertFromSnakeCase.
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
    let latitude:    Double?
    let longitude:   Double?
}
