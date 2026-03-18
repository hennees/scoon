import Foundation

enum SpotMapper {
    static func map(_ dto: SpotDTO) -> Spot {
        Spot(
            id:          UUID(uuidString: dto.id) ?? UUID(),
            name:        dto.name,
            location:    dto.location,
            rating:      dto.rating,
            imageURL:    dto.imageUrl,
            isFavorite:  dto.isFavorite,
            description: dto.description,
            viewCount:   dto.viewCount,
            likeCount:   dto.likeCount,
            saveCount:   dto.saveCount,
            distance:    dto.distance,
            category:    SpotCategory(rawValue: dto.category) ?? .urban,
            latitude:    dto.latitude,
            longitude:   dto.longitude,
            creatorId:   dto.creatorId.flatMap(UUID.init(uuidString:))
        )
    }
}
