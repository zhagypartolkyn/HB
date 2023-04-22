 

import FirebaseFirestore

struct Report: Codable {
    var id: String
    var report: ReportContent
    var object: ReportObject
    var status: ReportStatus
    var date: ReportDate
}

struct ReportContent: Codable {
    var uid: String?
    var type: String?
    var comment: String?
}

struct ReportObject: Codable {
    var id: String?
    var type: String?
    var uid: String?
}

struct ReportStatus: Codable {
    var active: Bool = true
}

struct ReportDate: Codable {
    var closed: Timestamp?
    var publish: Timestamp?
}
