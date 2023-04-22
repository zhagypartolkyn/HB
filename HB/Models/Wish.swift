 

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Wish: Codable {
    var id: String?
    var title: String?
    var description: String?
    var image: String?
    var type: String = "group"
    var status: WishStatus
    var location: Location
    var date: WishDate
    var likes: [String] = []
    var participants: [String] = []
    var refused: [String] = []
    var history: Int = 0
    var author: Author
    
    var users: [String: Votes]?
    
    var top: Top?
    
    var showOnMap: Bool = false
    var allowAddHistory: Bool = true
}

struct Votes: Codable {
    var uid: String?
    var wishId: String?
    var upVote: Bool?
}


struct Top: Codable, Hashable {
    var status: Bool = false
    var votes: Int = 0
}

struct WishStatus: Codable {
    var complete: Bool = false
    var matched: Bool = false
    var delete: Bool = false
    var banned: Bool = false
    var request: Bool = false
    var message: Bool = false
}

struct WishDate: Codable {
    var publish: Timestamp?
    var update: Timestamp?
    var until: Timestamp?
    var complete: Timestamp?
    var delete: Timestamp?
}

struct Author: Codable, Hashable {
    internal init(uid: String, username: String, thumb: String, gender: String, birthday: Timestamp) {
        self.uid = uid
        self.username = username
        self.thumb = thumb
        self.gender = gender
        self.birthday = birthday
    }
    
    var uid: String
    var username: String
    var thumb: String
    var gender: String
    var birthday: Timestamp
}

let locationExample = Location(
    city: "Almaty",
    country: "Kazakhstan",
    countryCode: "KZ",
    placeId: "kz_almaty",
    geoPoint: GeoPoint(latitude: 43.121, longitude: 73.123),
    placeName: "Almaty"
)

let authorExample = Author(
    uid: "uid",
    username: "DanaBanana",
    thumb: "https://firebasestorage.googleapis.com/v0/b/wanti-71794.appspot.com/o/users%2FJvBDOiP4UVaXxTlGKAuTZrphzP62%2Favatar%2Fthumb.jpg?alt=media&token=d7065c07-36eb-4a67-b157-15c12d88aeef",
    gender: "male",
    birthday: Timestamp(date: Date())
)

let topExample = Top(
    status: false,
    votes: 0)

let wishExample = Wish(
    id: "123",
    title: "Хочу посетить автодром СТК SOKOL. Кто хочет потягаться со мной?)",
    description: "Хочу открыть свой ресторан в Алматы. NazimaRestoBar скоро)",
    image: "https://firebasestorage.googleapis.com/v0/b/wanti-71794.appspot.com/o/wish%2Fphoto%2FDIwEsoIxkh04ilTrpAd0.jpg?alt=media&token=3b300bb1-ed10-4ce0-80e3-cb2fd687fbf4",
    type: "group",
    status: WishStatus(
        complete: false,
        matched: false,
        delete: false,
        banned: false,
        request: false,
        message: false
    ),
    location: locationExample,
    date: WishDate(
        publish: Timestamp(date: Date()),
        update: Timestamp(date: Date()),
        until: Timestamp(date: Date()),
        complete: Timestamp(date: Date()),
        delete: Timestamp(date: Date())
    ),
    likes: [],
    participants: [],
    refused: [],
    history: 12,
    author: authorExample, top: topExample,
    showOnMap: false,
    allowAddHistory: true
)
