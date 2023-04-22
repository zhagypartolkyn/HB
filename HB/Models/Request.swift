 

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Request: Codable {
    var id: String
    var wish: WishInfo
    var author: Author
    var status: StatusRequest
    var date: MiniDate
    var text: String?
    var to: String?
}

struct StatusRequest: Codable {
    var delete: Bool = false
    var accept: Bool = false
    var decline: Bool = false
}
