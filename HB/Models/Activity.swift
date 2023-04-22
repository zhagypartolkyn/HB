 

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Activity: Codable {
    var id: String
    var type: String?
    var to: String?
    var author: Author
    var wish: WishInfo
    var status: NewsStatus
    var date: MiniDate
}

struct NewsStatus: Codable {
    var delete: Bool = false
    var read: Bool = false
}

let activityExample = Activity(
    id: "123",
    type: "follow",
    to: "321",
    author: authorExample,
    wish: WishInfo(id: "123", title: "Гоу в горы"),
    status: NewsStatus(delete: false, read: false),
    date: MiniDate(publish: Timestamp(date: Date()), delete: Timestamp(date: Date()))
)
