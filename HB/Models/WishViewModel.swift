 
import UIKit
import SwiftDate

struct WishViewModel: Identifiable, Equatable, Decodable, Hashable, DefaultConstructible {
    static func == (lhs: WishViewModel, rhs: WishViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let title: String
    let description: String
    let image: String
    let type: String
    
    let publishDate: String
    let publishInDate: Date
    let untilDate: String
    let completedDate: String
    
    let isComplete: Bool
    let isHistories: Bool
    let isMyWish: Bool
    var isIParticipate: Bool
    let isGroupWish: Bool
    let isRequestsNotify: Bool
    let isChatNotify: Bool
    
    let uid: String
    let username: String
    let avatar: String
    
    let participants: [String]
    let author: Author
    let location: Location
    let numberOfHistories: String
    let numberOfHistoriesText: String
    
    let top: Top?
    
    
    // Dependency Injection (DI)
    init(value: Codable) {
        let wish = value as! Wish
        
        self.id = wish.id ?? ""
        self.title = wish.title ?? ""
        self.description = wish.description ?? ""
        self.type = wish.type
        self.numberOfHistories = String(wish.history)
        if let image = wish.image {
            self.image = image
        } else {
            self.image = ""
        }
        
        self.publishDate = wish.date.publish!.dateValue().toRelative(style: RelativeFormatter.defaultStyle(), locale: Locale.current)
        self.publishInDate = wish.date.publish!.dateValue()
        if let completedDate = wish.date.complete {
            self.completedDate = completedDate.dateValue().toRelative(style: RelativeFormatter.defaultStyle(), locale: Locale.current)
        } else {
            self.completedDate = ""
        }
        
        if let untilDate = wish.date.until {
            self.untilDate = "Дата завершения \(untilDate.dateValue().toRelative(style: RelativeFormatter.defaultStyle(), locale: Locale.current))"
        } else {
            self.untilDate = ""
        }
        
        self.isComplete = wish.status.complete
        self.isHistories = wish.history > 0
        self.isMyWish = wish.author.uid == DB.Helper.uid
        self.isIParticipate = wish.participants.contains(DB.Helper.uid)
        
        self.isGroupWish = wish.type == "group"
        self.isRequestsNotify = wish.status.request
        self.isChatNotify = wish.status.message
        
        self.uid = wish.author.uid
        self.username = wish.author.username
        self.avatar = wish.author.thumb
    
        self.participants = wish.participants
        self.author = wish.author
        self.location = wish.location
        self.numberOfHistoriesText = "\(LocalizedText.Interesting.HISTORY): \(wish.history)"
        
        self.top = wish.top 
    }
    
}
