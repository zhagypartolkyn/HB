

import UIKit
import SwiftDate

struct HistoryViewModel: Hashable, DefaultConstructible {

    let id: String
    let uid: String
    let avatar: String
    let username: String
    let title: String
    let publishDate: String
    let wishId: String
    let wishTitle: String
    let thumb: String
    let media: String
    var video: String?
    let mediaType: MediaType
    var complete: Bool?
    var showOnDiscovery: Bool?
    
    // Dependency Injection (DI)
    init(value: Codable) {
        let history = value as! History
        
        self.id = history.id ?? ""
        self.uid = history.author.uid
        self.avatar = history.author.thumb
        self.username = history.author.username
        self.title = history.text ?? ""
        self.publishDate = history.date.publish!.dateValue().toRelative(style: RelativeFormatter.defaultStyle(), locale: Locale.current)
        self.wishId = history.wish.id!
        self.wishTitle = history.wish.title!
        
        if history.type.photo {
            mediaType = .photo
            self.media = history.image!
            self.complete = true
        } else {
            mediaType = .video
            self.media = history.image!
            self.video = history.video
        }
        
        self.thumb = history.thumb!
        self.complete = history.complete
        self.showOnDiscovery = history.showOnDiscovery
    }

}

enum MediaType {
    case photo, video
}
