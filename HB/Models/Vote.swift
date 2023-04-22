 


import FirebaseFirestore

struct Vote: Codable {
    var wishId: String
    var uid: String
    var upVote: Bool
}
