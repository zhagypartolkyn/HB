 

import Foundation

// MARK: - UserJsonWelcome
struct UserJsonWelcome: Codable {
    let took: Int
    let timedOut: Bool
    let shards: UserJsonShards
    let hits: UserJsonHits?

    enum CodingKeys: String, CodingKey {
        case took
        case timedOut = "timed_out"
        case shards = "_shards"
        case hits
    }
}

// MARK: - UserJsonHits
struct UserJsonHits: Codable {
    let total: UserJsonTotal
    let maxScore: Double?
    let hits: [UserJsonHit]?

    enum CodingKeys: String, CodingKey {
        case total
        case maxScore = "max_score"
        case hits
    }
}

// MARK: - UserJsonHit
struct UserJsonHit: Codable {
    let index, type, id: String
    let score: Double
    let source: UserJsonSource?

    enum CodingKeys: String, CodingKey {
        case index = "_index"
        case type = "_type"
        case id = "_id"
        case score = "_score"
        case source = "_source"
    }
}

// MARK: - UserJsonSource
struct UserJsonSource: Codable {
    let accounts: UserJsonAccounts?
    let avatar: UserJsonAvatar?
    let ban: UserJsonBan?
    let birthday: UserJsonBirthday?
    let counters: UserJsonCounters?
    let date: UserJsonDate?
    let email: String?
    let following: [String]
    let gender: String?
    let location: UserJsonLocation?
    let online: UserJsonOnline?
    let status: UserJsonStatus?
    let uid, username: String
    let geoPoint: UserJsonSourceGeoPoint?
}

// MARK: - UserJsonAccounts
struct UserJsonAccounts: Codable {
    let apple, facebook, google, password: Bool
    let phone, twitter: Bool
}

// MARK: - UserJsonAvatar
struct UserJsonAvatar: Codable {
    let large, thumb: String?
}

// MARK: - UserJsonBan
struct UserJsonBan: Codable {
    let count: Int?
    let status: Bool?
}

// MARK: - UserJsonBirthday
struct UserJsonBirthday: Codable {
    let seconds, nanoseconds: Int?
}

// MARK: - UserJsonCounters
struct UserJsonCounters: Codable {
    let connects, followers, followings, wishes: Int?
}

// MARK: - UserJsonDate
struct UserJsonDate: Codable {
    let publish, update: UserJsonBirthday?
}

// MARK: - UserJsonSourceGeoPoint
struct UserJsonSourceGeoPoint: Codable {
    let lat, lon: Double
}

// MARK: - UserJsonLocation
struct UserJsonLocation: Codable {
    let city, country, countryCode: String?
    let geoPoint: UserJsonLocationGeoPoint?
    let placeID, placeName: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, geoPoint
        case placeID = "placeId"
        case placeName
    }
}

// MARK: - UserJsonLocationGeoPoint
struct UserJsonLocationGeoPoint: Codable {
    let latitude, longitude: Double
}

// MARK: - UserJsonOnline
struct UserJsonOnline: Codable {
    let latest: UserJsonLatest?
    let status: Bool
}

// MARK: - UserJsonLatest
struct UserJsonLatest: Codable {
    let seconds, nanoseconds: Int

    enum CodingKeys: String, CodingKey {
        case seconds = "_seconds"
        case nanoseconds = "_nanoseconds"
    }
}

// MARK: - UserJsonStatus
struct UserJsonStatus: Codable {
    let close, correct, delete, notifications: Bool
    let socialCorrect: Bool
}

// MARK: - UserJsonTotal
struct UserJsonTotal: Codable {
    let value: Int
    let relation: String
}

// MARK: - UserJsonShards
struct UserJsonShards: Codable {
    let total, successful, skipped, failed: Int
}
