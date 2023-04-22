 

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Room: Codable {
    var id: String
    var typeIsGroup: Bool = true
    var wish: WishInfo
    var participants: [String] = []
    var refused: [String] = []
    var users: [String: RoomUser]
    var message: RoomMessage
    var status: RoomStatus
    var date: MiniDate
}

struct RoomUser: Codable {
    var uid: String?
    var username: String?
    var thumb: String?
    var read: Bool = false
    var role: String = "participant"
    var isDeleted: Bool = false
    var inChat: Bool = false
}

struct RoomMessage: Codable {
    var text: String?
    var type: String?
    var date: Timestamp?
}

struct RoomStatus: Codable {
    var complete: Bool = false
    var delete: Bool = false
}
