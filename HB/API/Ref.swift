 

import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

enum Ref {
    
    // MARK: - FIRESTORE
    enum Fire {
        static let root: Firestore = Firestore.firestore()
        // USERS
        static let users: CollectionReference = root.collection("users")
        static func user(uid: String) -> DocumentReference { return users.document(uid) }
        // CONNECTS
        static let connects: CollectionReference = root.collection("connects")
        static func connect(uid: String) -> DocumentReference { return connects.document(uid) }
        // WISHES
        static let wishes: CollectionReference = root.collection("wishes") 
        static func wish(id: String) -> DocumentReference { return wishes.document(id) }
        static func votes(id: String) -> CollectionReference { return wishes.document(id).collection("votes")
        }
        // HISTORIES
        static let histories: CollectionReference = root.collection("histories")
        static func history(id: String) -> DocumentReference { return histories.document(id) }
        // REQUESTS
        static let requests: CollectionReference = root.collection("requests")
        static func request(id: String) -> DocumentReference { return requests.document(id) }
        // NOTIFICATIONS
        static let notifications: CollectionReference = root.collection("notifications")
        static func notification(id: String) -> DocumentReference { return notifications.document(id) }
        // ROOMS
        static let rooms: CollectionReference = root.collection("rooms")
        static func room(id: String) -> DocumentReference { return rooms.document(id) }
        // Room Notify
        static let notifies: CollectionReference = root.collection("rooms_notify")
        static func notify(id: String) -> DocumentReference { return notifies.document(id) }
        // Room Notify
        static let randomWishes: CollectionReference = root.collection("random_wish")
        // Reports
        static let reports: CollectionReference = root.collection("reports")
        // Reports
        static let reservedUsernames: CollectionReference = root.collection("reserved_usernames")
        // Blocked Users
        static let blockedUsers: CollectionReference = root.collection("blocked_users")
        static func myBlockedUsers(uid: String) -> CollectionReference { return blockedUsers.document(uid).collection("users") }
    }
    
    // MARK: - REALTIME
    enum Real {
        static let root: DatabaseReference = Database.database().reference()
        // CHATS
        static let chats: DatabaseReference = root.child("chats")
        static func chat(id: String) -> DatabaseReference { return chats.child(id) }
    }
    
    // MARK: - STORAGE
    enum Store {
        static let root = Storage.storage().reference(forURL: Constants.Links.storage)
        // USER AVATAR
        static func avatar(uid: String, name: String) -> StorageReference {
//            let id = UUID().uuidString // BUG: -ava
//            return root.child("users/\(uid)/avatar/\(name)_\(id).jpg")
            return root.child("users/\(uid)/avatar/\(name).jpg")
        }
        // WISH COVER
        static func wish(id: String, name: String) -> StorageReference {
            return root.child("wishes/\(id)/\(name).jpg")
        }
        // WISH HISTORY MEDIA
        static func history(wishId: String, historyId: String, name: String, isVideo: Bool) -> StorageReference {
            if isVideo {
                return root.child("wishes\(wishId)/histories/\(historyId)/\(name).mov")
            } else {
                return root.child("wishes/\(wishId)/histories/\(historyId)/\(name).jpg")
            }
        }
        // MESSAGE MEDIA
        static func message(roomId: String, name: String, isVideo: Bool) -> StorageReference {
            if isVideo {
                return root.child("chats/\(roomId)/\(name).mov")
            } else {
                return root.child("chats/\(roomId)/\(name).jpg")
            }
        }
    }
    
    // MARK: - USER MODEL
    enum General {
        static let id: String = "id"
    }
    
    enum User {
        static let uid: String = "uid"
        static let name: String = "name"
        static let username: String = "username"
        static let bio: String = "bio"
        static let gender: String = "gender"
        static let birthday: String = "birthday"
        static let email: String = "email"
        static let phone: String = "phone"
        static let following: String = "following"
        
        enum counters {
            static let followers: String = "counters.followers"
            static let followings: String = "counters.followings"
            static let wishes: String = "counters.wishes"
            static let connects: String = "counters.connects"
        }

        enum avatar {
            static let large: String = "avatar.large"
            static let thumb: String = "avatar.thumb"
        }
        
        static let location = Ref.Location.self

        enum status {
            static let correct: String = "status.correct"
            static let socialCorrect: String = "status.socialCorrect"
            static let close: String = "status.close"
            static let notifications: String = "status.notifications"
            static let delete: String = "status.delete"
        }

        enum ban {
            static let status: String = "ban.status"
            static let count: String = "ban.count"
            static let date: String = "ban.date"
            static let until: String = "ban.until"
        }

        enum online {
            static let status: String = "online.status"
            static let latest: String = "online.latest"
        }

        enum accounts {
            static let password: String = "accounts.password"
            static let phone: String = "accounts.phone"
            static let google: String = "accounts.google"
            static let facebook: String = "accounts.facebook"
            static let twitter: String = "accounts.twitter"
            static let apple: String = "accounts.apple"
        }
        
        enum date {
            static let delete: String = "date.delete"
            static let update: String = "date.update"
            static let publish: String = "date.publish"
        }
    }
    
    // MARK: - CONNECTS MODEL
    struct Connect {
        static let uid: String = "uid"
        static let visible: String = "visible"
        static let wishId: String = "wishId"
        
        static let connects = "connects"
        struct Connects {
            static let uid = "connects.uid"
            static let visible = "connects.visible"
            static let wishId = "connects.wishId"
        }
    }
    
    // MARK: - WISH MODEL
    enum Wish {
        static let id: String = "id"
        static let title: String = "title"
        static let description: String = "description"
        static let image: String = "image"
        static let type: String = "type"
        static let showOnMap: String = "showOnMap"
        static let allowAddHistory: String = "allowAddHistory"
        
        enum status {
            static let complete: String = "status.complete"
            static let matched: String = "status.matched"
            static let delete: String = "status.delete"
            static let banned: String = "status.banned"
            static let request: String = "status.request"
            static let message: String = "status.message"
        }
        
        static let location = Ref.Location.self
        
        enum date {
            static let publish: String = "date.publish"
            static let update: String = "date.update"
            static let until: String = "date.until"
            static let complete: String = "date.complete"
            static let delete: String = "date.delete"
        }
        
        static let likes: String = "likes"
        static let participants: String = "participants"
        static let refused: String = "refused"
        static let history: String = "history"
        
        static let author = Ref.Author.self
        
        
        enum top {
            static let status: String = "top.status"
            static let votes: String = "top.votes"
        }
        
    }
    
    // MARK: - HISTORY MODEL
    enum History {
        static let id: String = "id"
        static let wish = Ref.WishInfo.self
        static let author = Ref.Author.self
        enum status {
            static let delete: String = "status.delete"
            static let banned: String = "status.banned"
        }
        static let date = Ref.MiniDate.self
        static let text: String = "text"
        enum media {
            static let photo: String = "media.photo"
            static let thumb: String = "media.thumb"
            static let video: String = "media.video"
        }
        static let location = Ref.Location.self
    }
    
    // MARK: - REQUEST MODEL
    enum Request {
        static let id: String = "id"
        static let wish = Ref.WishInfo.self
        static let author = Ref.Author.self
        enum status {
            static let delete: String = "status.delete"
            static let accept: String = "status.accept"
            static let decline: String = "status.decline"
        }
        static let date = Ref.MiniDate.self
        static let text: String = "text"
        static let to: String = "to"
    }
    
    // MARK: - NOTIFICATION MODEL
    struct Notification {
        static let id: String = "id"
        static let type: String = "type"
        static let to: String = "to"
        static let author = Ref.Author.self
        static let wish = Ref.WishInfo.self
        enum status {
            static let delete = "status.delete"
            static let read = "status.read"
        }
        static let date = Ref.MiniDate.self
    }
    
    // MARK: - ROOM MODEL
    enum Room {
        static let id: String = "id"
        static let typeIsGroup: String = "typeIsGroup"
        static let wish = Ref.WishInfo.self
        static let participants: String = "participants"
        static let refused: String = "refused"
        static let users: String = "users"
        enum message {
            static let text: String = "message.text"
            static let type: String = "message.type"
            static let date: String = "message.date"
        }
        enum status {
            static let complete: String = "status.complete"
            static let delete: String = "status.delete"
        }
        static let date = Ref.MiniDate.self
    }
    
    // MARK: - MESSAGE MODEL
    enum Message {
        static let id: String = "id"
        static let uid: String = "uid"
        static let username: String = "username"
        static let date: String = "date"
        static let text: String = "text"
        static let type: String = "type"
        static let wishId: String = "wishId"
        static let wishTitle: String = "wishTitle"
        static let imageUrl: String = "imageUrl"
        static let videoUrl: String = "videoUrl"
    }
    
    // MARK: - MINI MODELS
    enum RoomUser {
        static let uid: String = "uid"
        static let username: String = "username"
        static let thumb: String = "thumb"
        static let read: String = "read"
        static let role: String = "role"
        static let isDeleted: String = "isDeleted"
        static let inChat: String = "inChat"
    }
    
    enum Location {
        static let city: String = "location.city"
        static let country: String = "location.country"
        static let countryCode: String = "location.countryCode"
        static let placeId: String = "location.placeId"
        static let geoPoint: String = "location.geoPoint"
        static let placeName: String = "location.placeName"
    }
    
    enum Author {
        static let uid: String = "author.uid"
        static let username: String = "author.username"
        static let thumb: String = "author.thumb"
        static let gender: String = "author.gender"
        static let birthday: String = "author.birthday"
    }
    
    enum WishInfo {
        static let id: String = "wish.id"
        static let title: String = "wish.title"
    }
    
    enum MiniDate {
        static let publish: String = "date.publish"
        static let delete: String = "date.delete"
    }
    
    // ADDITIONAL {
    enum GenderType {
        static let male: String = "male"
        static let female: String = "female"
    }

//    enum WishType {
//        static let single: String = "single"
//        static let group: String = "group"
//    }
    
    enum Image {
        static let thumb: String = "thumb"
        static let large: String = "large"
    }

    enum alert {
        static let loading: String = "loading"
        static let dismiss: String = "dismiss"
        static let success: String = "success"
        static let error: String = "error"
    }
    
}
