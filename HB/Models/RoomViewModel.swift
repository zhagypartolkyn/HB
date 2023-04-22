 

import UIKit
import SwiftDate
import Firebase
import FirebaseFirestore

final class RoomViewModel: Equatable, DefaultConstructible {
    
    static func == (lhs: RoomViewModel, rhs: RoomViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let messageText: String
    let messageTime: String
    
    let typeIsGroup: Bool
    let author: RoomUser
    let participants: [String]
    
    let wishId: String
    let wishTitle: String
    
    let name: String
    let partnerUid: String
    
    var allUsers: [String: RoomUser]
    var activeUsers: [String: RoomUser]
    var onlineUsers: [String: RoomUser]
    var deletedUsers: [String: RoomUser]
    
    var firstUserThumb: String = ""
    var secondUserThumb: String = ""
    
    var userListener: ListenerRegistration?
    
    // Dependency Injection (DI)
    init(value: Codable) {
        let room = value as! Room
        
        self.id = room.id
        
        switch room.message.type {
        case "text": messageText = room.message.text ?? "Сообщение не найдено"
        case "video": messageText = "Видео"
        case "image": messageText = "Фото"
        case "info": messageText = room.message.text ?? "Сообщение не найдено"
        default: messageText = "Тип не опознан"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        self.messageTime = dateFormatter.string(from: room.message.date?.dateValue() ?? Date())
        
        self.typeIsGroup = room.typeIsGroup
        self.author = room.users.values.filter { $0.role == "admin" }[0]
        self.participants = room.participants
        
        self.wishId = room.wish.id ?? ""
        self.wishTitle = room.wish.title ?? "Заголовок желания"
        
        self.allUsers = room.users
        self.activeUsers = room.users.filter { !$0.value.isDeleted }
        self.onlineUsers = room.users.filter { $0.value.inChat}
        self.deletedUsers = room.users.filter { $0.value.isDeleted }
        
        if room.typeIsGroup {
            self.name = LocalizedText.addWish.GROUP
            self.partnerUid = ""
        } else {
            let partnerUser = room.users.filter { $0.value.uid != DB.Helper.uid }[0].value
            
            self.name = "@\(partnerUser.username ?? "Имя пользователя")"
            self.partnerUid = partnerUser.uid ?? ""
        }
        
        // Room Avatars
        if room.typeIsGroup {
            switch activeUsers.count {
            case 0:
                firstUserThumb = DB.Helper.thumb.absoluteString
                secondUserThumb = ""
            case 1:
                firstUserThumb = DB.Helper.thumb.absoluteString
                secondUserThumb = ""
            case 2:
                firstUserThumb = activeUsers.filter { $0.value.uid != DB.Helper.uid }[0].value.thumb ?? "no avatar"
                secondUserThumb = DB.Helper.thumb.absoluteString
            default:
                var otherUsers = [RoomUser]()
                otherUsers.append(contentsOf: activeUsers.filter{ $0.value.uid != DB.Helper.uid }.values)
                firstUserThumb = otherUsers[0].thumb ?? "no avatar"
                secondUserThumb = otherUsers[1].thumb ?? "no avatar"
            }
        } else {
            let otherUsers = activeUsers.filter({ $0.value.uid != DB.Helper.uid })
            if let user = otherUsers.first {
                firstUserThumb = user.value.thumb ?? "no avatar"
            } else {
                firstUserThumb = DB.Helper.thumb.absoluteString
            }
            
        }
        
    }
    
}
