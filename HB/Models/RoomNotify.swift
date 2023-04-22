 
 
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RoomNotify: Codable {
    var id: String?
    var users: [String: Bool]
}
