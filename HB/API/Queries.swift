

import FirebaseFirestore

enum Queries {
    
    // MARK: - User
    enum User {
        static func recommend(limit: Int) -> Query {
            return Ref.Fire.users
                .whereField(Ref.User.status.correct, isEqualTo: true)
                .whereField(Ref.User.status.delete, isEqualTo: false)
                .whereField(Ref.User.ban.status, isEqualTo: false)
                .order(by: Ref.User.counters.wishes, descending: true)
                .limit(to: limit)
        }
        
        static func placeId(placeId: String, lastDocumentSnapshot: DocumentSnapshot?, limit: Int) -> Query {
            var query = Ref.Fire.users
                    .whereField(Ref.User.status.correct, isEqualTo: true)
                    .whereField(Ref.User.status.delete, isEqualTo: false)
                    .whereField(Ref.User.status.close, isEqualTo: false)
                    .whereField(Ref.User.ban.status, isEqualTo: false)
                    .order(by: Ref.User.date.update, descending: true)
                    .limit(to: limit)
            
            if placeId != UserLocationType.world.rawValue {
                query = query.whereField(Ref.Wish.location.placeId, isEqualTo: placeId)
            }
            
            if let lastDocumentSnapshot = lastDocumentSnapshot {
                query = query.start(afterDocument: lastDocumentSnapshot)
            }
            return query
        }
        
        static func newbie(placeId: String, lastDocumentSnapshot: DocumentSnapshot?, limit: Int) -> Query {
            var query = Ref.Fire.users
                    .whereField(Ref.User.status.correct, isEqualTo: true)
                    .whereField(Ref.User.status.delete, isEqualTo: false)
                    .whereField(Ref.User.status.close, isEqualTo: false)
                    .whereField(Ref.User.ban.status, isEqualTo: false)
                    .order(by: Ref.User.date.publish, descending: true)
                    .limit(to: limit)
            
            if let lastDocumentSnapshot = lastDocumentSnapshot {
                query = query.start(afterDocument: lastDocumentSnapshot)
            }
            return query
        }
        
        static func username(_ username: String) -> Query {
            return Ref.Fire.users.whereField(Ref.User.username, isEqualTo: username)
        }
        
        static func reserverUsername(_ username: String) -> Query {
            return Ref.Fire.reservedUsernames.whereField(Ref.User.username, isEqualTo: username)
        }
    }
    
    // MARK: - Follow
    enum Follow {
        static func check(uid: String) -> Query {
            return Ref.Fire.users
                .whereField(Ref.User.uid, isEqualTo: DB.Helper.uid)
                .whereField(Ref.User.following, arrayContains: uid)
        }
    }
    
    // MARK: - Wish
    enum Wish {
        static func feed(users: [String], limit: Int) -> Query {
            return Ref.Fire.wishes
                .whereField(Ref.Wish.author.uid, in: users)
                .whereField(Ref.Wish.status.delete, isEqualTo: false)
                .whereField(Ref.Wish.status.banned, isEqualTo: false)
                .order(by: Ref.Wish.date.update, descending: true)
                .limit(to: limit)
        }
        
        static func city(placeId: String, lastDocumentSnapshot: DocumentSnapshot?) -> Query {
            var query = Ref.Fire.wishes
                .whereField(Ref.Wish.status.complete, isEqualTo: false)
                .whereField(Ref.Wish.status.matched, isEqualTo: false)
                .whereField(Ref.Wish.status.delete, isEqualTo: false)
                .whereField(Ref.Wish.status.banned, isEqualTo: false)
                .order(by: Ref.Wish.date.publish, descending: true)
            
            if placeId != UserLocationType.world.rawValue {
                query = query.whereField(Ref.Wish.location.placeId, isEqualTo: placeId)
            }
            
            if let lastDocumentSnapshot = lastDocumentSnapshot {
                query = query.start(afterDocument: lastDocumentSnapshot)
            }
            return query
        }
        
        static func top(placeId: String, lastDocumentSnapshot: DocumentSnapshot?) -> Query {
            
            if placeId != UserLocationType.world.rawValue {
                var query = Ref.Fire.wishes
                    .whereField(Ref.Wish.location.placeId, isEqualTo: placeId)
                    .whereField(Ref.Wish.status.complete, isEqualTo: false)
                    .whereField(Ref.Wish.status.matched, isEqualTo: false)
                    .whereField(Ref.Wish.status.delete, isEqualTo: false)
                    .whereField(Ref.Wish.status.banned, isEqualTo: false)
                    .whereField(Ref.Wish.top.status, isEqualTo: true)
                    .whereField(Ref.Wish.top.votes, isGreaterThan: 0)
                    .order(by: Ref.Wish.top.votes, descending: true)
                    .order(by: Ref.Wish.date.publish, descending: true)
                
                if let lastDocumentSnapshot = lastDocumentSnapshot {
                    query = query.start(afterDocument: lastDocumentSnapshot)
                }
                return query
            } else {
                var query = Ref.Fire.wishes
                    .whereField(Ref.Wish.status.complete, isEqualTo: false)
                    .whereField(Ref.Wish.status.matched, isEqualTo: false)
                    .whereField(Ref.Wish.status.delete, isEqualTo: false)
                    .whereField(Ref.Wish.status.banned, isEqualTo: false)
                    .whereField(Ref.Wish.top.status, isEqualTo: true)
                    .whereField(Ref.Wish.top.votes, isGreaterThan: 0)
                    .order(by: Ref.Wish.top.votes, descending: true)
                    .order(by: Ref.Wish.date.publish, descending: true)
                
                if let lastDocumentSnapshot = lastDocumentSnapshot {
                    query = query.start(afterDocument: lastDocumentSnapshot)
                }
                return query
            }
        }
        
        static func map(placeId: String, lastDocumentSnapshot: DocumentSnapshot?) -> Query {
            var query = Ref.Fire.wishes
                .whereField(Ref.Wish.showOnMap, isEqualTo: true)
                .whereField(Ref.Wish.status.complete, isEqualTo: false)
                .whereField(Ref.Wish.status.matched, isEqualTo: false)
                .whereField(Ref.Wish.status.delete, isEqualTo: false)
                .whereField(Ref.Wish.status.banned, isEqualTo: false)
                .order(by: Ref.Wish.date.publish, descending: true)
            
            if placeId != UserLocationType.world.rawValue {
                query = query.whereField(Ref.Wish.location.placeId, isEqualTo: placeId)
            }
            
            if let lastDocumentSnapshot = lastDocumentSnapshot {
                query = query.start(afterDocument: lastDocumentSnapshot)
            }
            return query
        }
        
        static func user(uid: String, completed: Bool, limit: Int) -> Query {
            return Ref.Fire.wishes
                .whereField(Ref.Wish.author.uid, isEqualTo: uid)
                .whereField(Ref.Wish.status.complete, isEqualTo: completed)
                .whereField(Ref.Wish.status.delete, isEqualTo: false)
                .whereField(Ref.Wish.status.banned, isEqualTo: false)
                .order(by: Ref.Wish.date.update, descending: true)
                .limit(to: limit)
        }
        
        static func participant(uid: String, limit: Int) -> Query {
            return Ref.Fire.wishes
                .whereField(Ref.Wish.participants, arrayContains: uid)
                .whereField(Ref.Wish.status.delete, isEqualTo: false)
                .whereField(Ref.Wish.status.banned, isEqualTo: false)
                .order(by: Ref.Wish.date.update, descending: true)
                .limit(to: limit)
        }
    }
    
    // MARK: - History
    enum History {
        static func wish(withId wishId: String) -> Query {
            return Ref.Fire.histories
                .whereField(Ref.History.wish.id, isEqualTo: wishId)
                .whereField(Ref.History.status.delete, isEqualTo: false)
                .whereField(Ref.History.status.banned, isEqualTo: false)
                .order(by: Ref.History.date.publish, descending: true)
        }
        
        static func place(withId placeId: String) -> Query {
            var query = Ref.Fire.histories
                .whereField(Ref.History.status.delete, isEqualTo: false)
                .whereField(Ref.History.status.banned, isEqualTo: false)
                .order(by: Ref.History.date.publish, descending: true)
            
            if placeId != UserLocationType.world.rawValue {
                query = query.whereField(Ref.Wish.location.placeId, isEqualTo: placeId)
            }
            return query
        }
    }
    
    // MARK: - Notification
    enum Notification {
        static func fetch(lastDocumentSnapshot: DocumentSnapshot?) -> Query {
            var query = Ref.Fire.notifications
                .whereField(Ref.Notification.to, isEqualTo: DB.Helper.uid)
                .whereField(Ref.Notification.status.delete, isEqualTo: false)
                .order(by: Ref.Notification.date.publish, descending: true)
            if let lastDocumentSnapshot = lastDocumentSnapshot {
                query = query.start(afterDocument: lastDocumentSnapshot)
            }
            return query
        }
        
        static func unreads() -> Query {
            return Ref.Fire.notifications
                .whereField(Ref.Notification.to, isEqualTo: DB.Helper.uid)
                .whereField(Ref.Notification.status.delete, isEqualTo: false)
                .whereField(Ref.Notification.status.read, isEqualTo: false)
        }
    }
    
    // MARK: - Request
    enum Request {
        static func check(wishId: String) -> Query {
            return Ref.Fire.requests
                .whereField(Ref.Request.wish.id, isEqualTo: wishId)
                .whereField(Ref.Request.author.uid, isEqualTo: DB.Helper.uid)
        }
        
        static func fetch(wishId: String) -> Query {
            return Ref.Fire.requests
                .whereField(Ref.Request.wish.id, isEqualTo: wishId)
                .whereField(Ref.Request.status.accept, isEqualTo: false)
                .whereField(Ref.Request.status.decline, isEqualTo: false)
                .order(by: Ref.Request.date.publish, descending: true)
        }
    }
    
    // MARK: - Room
    enum Room {
        static func wish(id: String) -> Query {
            return Ref.Fire.rooms.whereField(Ref.Room.wish.id, isEqualTo: id)
        }
        
        static func myRooms(wishId: String?) -> Query {
            var query = Ref.Fire.rooms
                .whereField(Ref.Room.participants, arrayContains: DB.Helper.uid)
                .whereField(Ref.Room.status.delete, isEqualTo: false)
                .order(by: Ref.Room.message.date, descending: true)
            
            if let wishId = wishId {
                query = query.whereField(Ref.Room.wish.id, isEqualTo: wishId)
            }
            return query
        }
        
        static func myWithWish(id: String) -> Query {
            return Ref.Fire.rooms
                .whereField(Ref.Room.wish.id, isEqualTo: id)
                .whereField(Ref.Room.participants, arrayContains: DB.Helper.uid)
        }
        
        static func unreads() -> Query {
            return Ref.Fire.rooms
                .whereField("\(Ref.Room.users).\(DB.Helper.uid).\(Ref.RoomUser.read)", isEqualTo: false)
                .whereField(Ref.Room.participants, arrayContains: DB.Helper.uid)
                .whereField(Ref.Room.status.delete, isEqualTo: false)
        }
    }
    
    // MARK: - For wish delete
    enum onDelete {
        static func histories(wishId: String) -> Query {
            return Ref.Fire.histories.whereField(Ref.History.wish.id, isEqualTo: wishId)
        }
        
        static func rooms(wishId: String, uid: String? = nil) -> Query {
            if let uid = uid {
                return Ref.Fire.rooms
                    .whereField(Ref.Room.wish.id, isEqualTo: wishId)
                    .whereField(Ref.Room.participants, arrayContains: uid)
            } else {
                return Ref.Fire.rooms
                    .whereField(Ref.Room.wish.id, isEqualTo: wishId)
            }
        }
    
        static func requests(wishId: String) -> Query {
            return Ref.Fire.requests.whereField(Ref.Request.wish.id, isEqualTo: wishId)
        }
        
        static func myRequestsBy(wishId: String) -> Query {
            return Ref.Fire.requests
                .whereField(Ref.Request.author.uid, isEqualTo: DB.Helper.uid)
                .whereField(Ref.Request.wish.id, isEqualTo: wishId)
        }
    }
    
    // MARK: - Request
    enum RandomWish {
        static func fetch() -> Query {
            return Ref.Fire.randomWishes
        }
    }
    
    // MARK: - BlockedUser
    enum BlockedUser {
        static func checkIfIBlocked(uid: String, myUid: String) -> Query {
            return Ref.Fire.myBlockedUsers(uid: uid).whereField("uid", isEqualTo: myUid)
        }
    }
    
    // MARK: - Reports
//    enum Reports {
//        static func fetch() -> Query {
//            return Ref.Fire.randomWishes
//        }
//    }
    
}
