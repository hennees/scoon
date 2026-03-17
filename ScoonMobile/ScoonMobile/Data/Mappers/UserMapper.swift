import Foundation

enum UserMapper {
    static func map(_ dto: UserDTO) -> User {
        User(
            id:             UUID(uuidString: dto.id) ?? UUID(),
            username:       dto.username,
            email:          dto.email,
            bio:            dto.bio,
            avatarURL:      dto.avatar_url,
            postCount:      dto.post_count,
            followerCount:  dto.follower_count,
            followingCount: dto.following_count
        )
    }
}
