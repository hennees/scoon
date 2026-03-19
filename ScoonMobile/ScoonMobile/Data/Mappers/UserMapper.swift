import Foundation

enum UserMapper {
    static func map(_ dto: UserDTO) -> User {
        User(
            id:             UUID(uuidString: dto.id) ?? UUID(),
            username:       dto.username,
            email:          dto.email ?? "",
            bio:            dto.bio,
            avatarURL:      dto.avatarUrl,
            postCount:      dto.postCount,
            followerCount:  dto.followerCount,
            followingCount: dto.followingCount,
            isCreator:      dto.isCreator ?? false
        )
    }
}
