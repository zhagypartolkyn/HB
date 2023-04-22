 

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct History: Codable {
    var id: String?
    var wish: WishInfo
    var author: Author
    var status: HistoryStatus
    var date: MiniDate
    var text: String?
    var type: HistoryType
    var location: Location
    var thumb: String?
    var image: String?
    var video: String?
    var complete: Bool?
    var showOnDiscovery: Bool?
}

struct HistoryType: Codable {
    var photo: Bool
    var video: Bool
}

struct WishInfo: Codable {
    var id: String?
    var title: String?
}

struct HistoryStatus: Codable {
    var delete: Bool = false
    var banned: Bool = false
}

struct MiniDate: Codable {
    var publish: Timestamp?
    var delete: Timestamp?
}

let historyExample = History(
    id: "123",
    wish: WishInfo(id: "123", title: "Wish Title"),
    author: authorExample,
    status: HistoryStatus(delete: false, banned: false),
    date: MiniDate(publish: Timestamp(date: Date()), delete: Timestamp(date: Date())),
    text: "history yeeee",
    type: HistoryType(photo: true, video: true),
    location: locationExample,
    thumb: "https://firebasestorage.googleapis.com/v0/b/wanti-299809.appspot.com/o/users%2Fvwa0DkfoQyaZ78tTsNmaq3KJtnm1%2Fwishes%2FHvYTmBvzaUYUXG7OjMW3%2Fhistory%2F0ZN228EiJleIoY0RB8ze_thumb?alt=media&token=bdf0330b-535f-4ef6-94ab-83091869749d",
    image: "https://firebasestorage.googleapis.com/v0/b/wanti-299809.appspot.com/o/users%2Fvwa0DkfoQyaZ78tTsNmaq3KJtnm1%2Fwishes%2FHvYTmBvzaUYUXG7OjMW3%2Fhistory%2F0ZN228EiJleIoY0RB8ze?alt=media&token=15edd05a-67a4-4496-bca4-d68559213226",
    video: "https://firebasestorage.googleapis.com/v0/b/wanti-299809.appspot.com/o/wishesW3tf7gZfDLYbtqofJGRM%2Fhistories%2F3FHaFUa3qXFnYpPxNnvA%2Fvideo.mov?alt=media&token=2ae3453d-ddd3-4a38-b6b1-f31666cae542",
    complete: false,
    showOnDiscovery: true
)
