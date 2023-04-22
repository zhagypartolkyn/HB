 

import FirebaseFirestore

struct BlockedUser: Codable {
    var id: String
    var uid: String
    var date: Timestamp
}
