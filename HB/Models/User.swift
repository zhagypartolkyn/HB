 
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable {
    internal init(uid: String? = nil, name: String? = nil, username: String? = nil, bio: String? = nil, gender: String? = nil, birthday: Timestamp? = nil, email: String? = nil, phone: String? = nil, following: [String] = [], counters: UserCounters, avatar: UserAvatar, location: Location, status: UserStatus, ban: UserBan, online: UserOnline, accounts: UserAccounts, date: UserDate, verified: Bool? = false) {
        self.uid = uid
        self.name = name
        self.username = username
        self.bio = bio
        self.gender = gender
        self.birthday = birthday
        self.email = email
        self.phone = phone
        self.following = following
        self.counters = counters
        self.avatar = avatar
        self.location = location
        self.status = status
        self.ban = ban
        self.online = online
        self.accounts = accounts
        self.date = date
        self.verified = verified
    }
    
    var uid: String?
    var name: String?
    var username: String?
    var bio: String?
    var gender: String?
    var birthday: Timestamp?
    var email: String?
    var phone: String?
    var following: [String] = []
    var verified: Bool?
    
    var counters: UserCounters
    var avatar: UserAvatar
    var location: Location
    var status: UserStatus
    var ban: UserBan
    var online: UserOnline
    var accounts: UserAccounts
    var date: UserDate
}

struct UserCounters: Codable {
    var followers: Int = 0
    var followings: Int = 0
    var wishes: Int = 0
    var connects: Int? = 0
}

struct UserAvatar: Codable {
    var large: String?
    var thumb: String?
}

struct Location: Codable, Hashable {
    var city: String?
    var country: String?
    var countryCode: String?
    var placeId: String?
    var geoPoint: GeoPoint?
    var placeName: String?
}

struct UserStatus: Codable {
    var correct: Bool = false
    var socialCorrect: Bool = false
    var close: Bool = false
    var notifications: Bool = true
    var delete: Bool = false
}

struct UserSettings: Codable {
    var notifications: Bool = true
}

struct UserBan: Codable {
    var status: Bool = false
    var count: Int = 0
    var date: Timestamp?
    var until: Timestamp?
}

struct UserOnline: Codable {
    var status: Bool = false
    var latest: Timestamp?
}

struct UserAccounts: Codable {
    var password: Bool = false
    var phone: Bool = false
    var google: Bool = false
    var facebook: Bool = false
    var twitter: Bool = false
    var apple: Bool = false
}

struct UserDate: Codable {
    var delete: Timestamp?
    var publish: Timestamp?
    var update: Timestamp?
}

let userExample = User(
    uid: "hi",
    name: "Sapar Jumabekov",
    username: "sapa.tech",
    bio: "Pro pro",
    gender: "male",
    birthday: Timestamp(date: Date()),
    email: "sapa.tech@gmail.com",
    phone: "+77477773404",
    following: [],
    counters: UserCounters(),
    avatar: UserAvatar(large: "", thumb: ""),
    location: locationExample,
    status: UserStatus(),
    ban: UserBan(),
    online: UserOnline(),
    accounts: UserAccounts(),
    date: UserDate(),
    verified: true
)
