import Foundation

struct UserDTO: Codable {
    let id:             String
    let username:       String
    let email:          String
    let bio:            String
    let avatarUrl:      String
    let postCount:      Int
    let followerCount:  Int
    let followingCount: Int
    let isCreator:      Bool?   // optional for backwards compat with existing API responses
}
