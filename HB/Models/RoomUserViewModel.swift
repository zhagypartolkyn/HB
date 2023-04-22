 
 

import UIKit

final class RoomUserViewModel {
    
    let uid: String
    let username: String
    let thumb: String
    let isAdmin: Bool
    var hideDeleteButton: Bool
    var isDeleted: Bool
    // Dependency Injection (DI)
    init(user: RoomUser, author: RoomUser) {
        
        self.uid = user.uid ?? "1"
        self.username = user.username ?? "username"
        self.thumb = user.thumb ?? ""
        self.isAdmin = user.role == "admin"
        self.isDeleted = user.isDeleted
        if author.uid == DB.Helper.uid && user.uid != DB.Helper.uid {
            hideDeleteButton = false
        } else {
            hideDeleteButton = true
        }
    }
}
