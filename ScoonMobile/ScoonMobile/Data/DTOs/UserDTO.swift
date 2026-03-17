import Foundation

struct UserDTO: Codable {
    let id:              String
    let username:        String
    let email:           String
    let bio:             String
    let avatar_url:      String
    let post_count:      Int
    let follower_count:  Int
    let following_count: Int
}
