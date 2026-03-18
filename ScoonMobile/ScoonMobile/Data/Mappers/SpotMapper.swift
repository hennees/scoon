import Foundation

enum SpotMapper {
    static func map(_ dto: SpotDTO) -> Spot {
        Spot(
            id:          UUID(uuidString: dto.id) ?? UUID(),
            name:        dto.name,
            location:    dto.location,
            rating:      dto.rating,
            imageURL:    dto.image_url,
            isFavorite:  dto.is_favorite,
            description: dto.description,
            viewCount:   dto.view_count,
            likeCount:   dto.like_count,
            saveCount:   dto.save_count,
            distance:    dto.distance,
            category:    SpotCategory(rawValue: dto.category) ?? .urban,
            latitude:    dto.latitude,
            longitude:   dto.longitude
        )
    }
}
