 

import UIKit
import SwiftDate

enum NotificationType {
    case follow
    case request
    case error
}

final class ActivityViewModel: DefaultConstructible {
    let id: String
    let author: Author
    let publishDate: String
    
    let text: String
    let type: NotificationType
    
    let isRead: Bool
    var wishId: String = ""
    var wishText: String = ""
    
    // Dependency Injection (DI)
    init(value: Codable) {
        let activity = value as! Activity
        
        self.id = activity.id
        self.author = activity.author
        let dateAgo = activity.date.publish!.dateValue().toRelative(style: RelativeFormatter.twitterStyle(), locale: Locale.current)
        self.publishDate = dateAgo.replacingOccurrences(of: "-", with: "")
        
        self.wishId = activity.wish.id ?? ""
        self.wishText = activity.wish.title ?? "Wish not found"
        self.isRead = activity.status.read
        
        switch activity.type {
        case "follow":
            self.type = .follow
            self.text = "подписался(-ась) на вас"
        case "request":
            self.type = .request
            self.text = "отправил(-а) запрос на ваше желание"
        case .none:
            self.type = .follow
            self.text = "не опознанный тип"
        case .some(_):
            self.type = .follow
            self.text = "не опознанный тип"
        }
    }
}
