

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

enum DatabaseHelpers {
    
    // MARK: - AUTH VARIABLES
    static var uid: String {
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    
    static var username: String {
        return RealmHelper.getAuthor().username
    }
    
    static var thumb: URL {
        return URL(string: RealmHelper.getAuthor().thumb)!
    }
    
    // MARK: - USER ONLINE
    static func isOnline(bool: Bool) {
        if !DB.Helper.uid.isEmpty {
            Ref.Fire.user(uid: DB.Helper.uid).updateData([
                Ref.User.online.status: bool as Any,
                Ref.User.online.latest: Timestamp(date: Date()) as Any
            ])
        }
    }

    // MARK: - UPDATE USER
    static func updateUser(dict: [String: Any], completion: @escaping (Result<Bool, Error>) -> Void) {
        Ref.Fire.user(uid: DB.Helper.uid).updateData(dict) { (error) in
            if let err = error {
                completion(.failure(err))
                return
            }
            completion(.success(true))
        }
    }
    
    // MARK: - START FOLLOW
    static func startFollow(otherUserUid: String, batch: WriteBatch, completion: @escaping (Result<Bool, Error>) -> Void) {
        let otherUser = Ref.Fire.user(uid: otherUserUid)
        let me = Ref.Fire.user(uid: DB.Helper.uid)
        batch.updateData([Ref.User.counters.followers : FieldValue.increment(Int64(1))], forDocument: otherUser)
        batch.updateData([Ref.User.following : FieldValue.arrayUnion([otherUserUid])], forDocument: me)
        batch.updateData([Ref.User.counters.followings : FieldValue.increment(Int64(1))], forDocument: me)
        
        DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: me) { (result) in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let userVM):
                let refNotifications = Ref.Fire.notifications.document()
                
                let notification = Activity(
                    id: refNotifications.documentID,
                    type: "follow",
                    to: otherUserUid,
                    author: Author(
                        uid: userVM.uid,
                        username: userVM.username,
                        thumb: userVM.avatar,
                        gender: userVM.gender,
                        birthday: userVM.birthday
                    ),
                    wish: WishInfo(),
                    status: NewsStatus(),
                    date: MiniDate(publish: Timestamp(date: Date()))
                )
                
                DB.create(model: notification, ref: refNotifications) { (_) in }
                completion(.success(true))
            }
        }
    }
    
    // MARK: - STOP FOLLOW
    static func stopFollow(otherUserUid: String, batch: WriteBatch, completion: @escaping (Result<Bool, Error>) -> Void) {
        let otherUser = Ref.Fire.user(uid: otherUserUid)
        let me = Ref.Fire.user(uid: DB.Helper.uid)
        batch.updateData([Ref.User.counters.followers : FieldValue.increment(Int64(-1))], forDocument: otherUser)
        batch.updateData([Ref.User.following : FieldValue.arrayRemove([otherUserUid])], forDocument: me)
        batch.updateData([Ref.User.counters.followings : FieldValue.increment(Int64(-1))], forDocument: me)
        completion(.success(true))
    }
    
    // MARK: - CREATE MESSAGE
    static func createMessage(roomId: String, value: [String: Any]) {
        Ref.Real.chat(id: roomId).childByAutoId().updateChildValues(value)
        
        Ref.Fire.room(id: roomId).updateData([
            Ref.Room.message.text: value[Ref.Message.text] as Any,
            Ref.Room.message.type: value[Ref.Message.type] as Any,
            Ref.Room.message.date: Timestamp(date: Date())
        ])
        
        DB.fetchViewModel(model: Room.self, viewModel: RoomViewModel.self, ref: Ref.Fire.room(id: roomId)) { (result) in
            switch result {
            case .success(let roomVM):
                var unreadUsers: [String: RoomUser] = [:]
                for user in roomVM.allUsers {
                    var unreadUser = user.value
                    unreadUser.read = unreadUser.uid == DB.Helper.uid
                    unreadUsers[user.key] = unreadUser
                }
                
                do {
                    try Ref.Fire.room(id: roomVM.id).setData(from: ["users": unreadUsers], mergeFields: ["users"])
                } catch {
                    debugPrint(error)
                }
            case .failure(let error):
                debugPrint(error)
            }
        }

    }

    static func updateRoomUser(roomId: String, wishId: String, uid: String, request: Request? = nil, users: [String : RoomUser]? = nil, isDeleted: Bool, completionHandler: @escaping () -> Void) {
        let batchService = BatchService()
        
        batchService.performBatchOperation { (batch, commit) in
            
            if let users = users { // BUG:
                do {
                    try batch.setData(from: [Ref.Room.users: users], forDocument: Ref.Fire.room(id: roomId), mergeFields: [Ref.Room.users]) // BUG
                } catch {
                    debugPrint(error)
                }
            } else {
                batch.updateData(["\(Ref.Room.users).\(uid).isDeleted": isDeleted], forDocument: Ref.Fire.room(id: roomId))
            }
            
            if isDeleted {
                batch.updateData([Ref.Room.participants: FieldValue.arrayRemove([uid])], forDocument: Ref.Fire.room(id: roomId))
                batch.updateData([Ref.Room.refused: FieldValue.arrayUnion([uid])], forDocument: Ref.Fire.room(id: roomId))
                batch.updateData([Ref.Room.participants: FieldValue.arrayRemove([uid])], forDocument: Ref.Fire.wish(id: wishId))
                batch.updateData([Ref.Room.refused: FieldValue.arrayUnion([uid])], forDocument: Ref.Fire.wish(id: wishId))
            } else {
                batch.updateData([Ref.Room.participants: FieldValue.arrayUnion([uid])], forDocument: Ref.Fire.room(id: roomId))
                batch.updateData([Ref.Room.refused: FieldValue.arrayRemove([uid])], forDocument: Ref.Fire.room(id: roomId))
                batch.updateData([Ref.Room.participants: FieldValue.arrayUnion([uid])], forDocument: Ref.Fire.wish(id: wishId))
                batch.updateData([Ref.Room.refused: FieldValue.arrayRemove([uid])], forDocument: Ref.Fire.wish(id: wishId))
                
                if let request = request {
                    batch.updateData([Ref.Request.status.accept: true], forDocument: Ref.Fire.request(id: request.id))
                }
            }
            commit()
        } completionHandler: {
            completionHandler()
        }
    }
    
}
