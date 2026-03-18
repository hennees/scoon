import Foundation

struct User: Identifiable, Hashable {
    let id:             UUID
    let username:       String
    let email:          String
    let bio:            String
    let avatarURL:      String
    let postCount:      Int
    let followerCount:  Int
    let followingCount: Int
    let isCreator:      Bool
}
