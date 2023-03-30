

import FirebaseFirestore
import RealmSwift

class AuthorRealm: Object {
    @objc dynamic var uid: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var thumb: String = ""
    @objc dynamic var gender: String = ""
    @objc dynamic var birthday: Date = Date()
}

enum RealmHelper {
    static func updateFirebaseLocaleProfile(userVM: UserViewModel, completionHandler: @escaping (() -> Void)) {
        let author = AuthorRealm()
        author.uid = userVM.uid
        author.username = userVM.username
        author.thumb = userVM.avatar
        author.gender = userVM.gender
        author.birthday = userVM.birthday.dateValue()
        completionHandler()
    }
    
    static func getAuthor() -> Author {
        let realm = try! Realm()
        
        guard let authorRealm = realm.objects(AuthorRealm.self).first else {
            return Author(uid: "", username: "", thumb: "error", gender: "", birthday: Timestamp(date: Date()))
        }
        
        let author = Author(uid: authorRealm.uid,
                            username: authorRealm.username,
                            thumb: authorRealm.thumb,
                            gender: authorRealm.gender,
                            birthday: Timestamp(date: authorRealm.birthday))
        return author
    }
}
