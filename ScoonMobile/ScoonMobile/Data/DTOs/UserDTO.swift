import Foundation

struct UserDTO: Codable {
    let id:             String
    let username:       String
    let email:          String?  // not present in profiles table; only available from auth endpoint
    let bio:            String
    let avatarUrl:      String
    let postCount:      Int
    let followerCount:  Int
    let followingCount: Int
    let isCreator:      Bool?
}
