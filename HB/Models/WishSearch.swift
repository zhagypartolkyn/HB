 

import Foundation

struct WishSearch: Codable {
    let took: Int
    let timedOut: Bool
    let shards: Shards
    let hits: Hits?

    enum CodingKeys: String, CodingKey {
        case took
        case timedOut = "timed_out"
        case shards = "_shards"
        case hits
    }
}

// MARK: - Hits
struct Hits: Codable {
    let total: Total
    let maxScore: Double?
    let hits: [Hit]?

    enum CodingKeys: String, CodingKey {
        case total
        case maxScore = "max_score"
        case hits
    }
}

// MARK: - Hit
struct Hit: Codable {
    let index, type, id: String?
    let score: Double?
    let source: Source

    enum CodingKeys: String, CodingKey {
        case index = "_index"
        case type = "_type"
        case id = "_id"
        case score = "_score"
        case source = "_source"
    }
}

// MARK: - Source
struct Source: Codable {
    let allowAddHistory: Bool
    let author: AuthorWish
    let date: DateClass
    let sourceDescription: String
    let history: Int
    let id: String?
    let likes: [String]
    let location: LocationWish
    let participants, refused: [String]
    let showOnMap: Bool
    let status: Status
    let title, type: String
    let geoPoint: SourceGeoPoint?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case allowAddHistory, author, date
        case sourceDescription = "description"
        case history, id, likes, location, participants, refused, showOnMap, status, title, type, geoPoint, image
    }
}

// MARK: - Author
struct AuthorWish: Codable {
    let birthday: Birthday
    let gender: String
    let thumb: String
    let uid, username: String
}

// MARK: - Birthday
struct Birthday: Codable {
    let seconds: Int64
    let nanoseconds: Int32
}

// MARK: - DateClass
struct DateClass: Codable {
    let publish, update: Birthday
}

// MARK: - SourceGeoPoint
struct SourceGeoPoint: Codable {
    let lat, lon: Double
}

// MARK: - Location
struct LocationWish: Codable {
    let city: String?
    let country, countryCode: String?
    let geoPoint: LocationGeoPoint?
    let placeID: String?

    enum CodingKeys: String, CodingKey {
        case city, country, countryCode, geoPoint
        case placeID = "placeId"
    }
}

// MARK: - LocationGeoPoint
struct LocationGeoPoint: Codable {
    let latitude, longitude: Double
}

// MARK: - Status
struct Status: Codable {
    let banned, complete, delete, matched: Bool
    let message, request: Bool
}

// MARK: - Total
struct Total: Codable {
    let value: Int
    let relation: String
}

// MARK: - Shards
struct Shards: Codable {
    let total, successful, skipped, failed: Int
}


