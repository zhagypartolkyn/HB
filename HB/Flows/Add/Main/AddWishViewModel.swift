 

import Foundation
import FirebaseFirestore
import Firebase

class AddWishViewModel {
    
    // MARK: - Binding
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    var navigateBack: (() -> Void)?
    var navigateMap: ((_ delegate: HandleAddCoordinate) -> Void)?
    
    // MARK: - Variables
    private let author = RealmHelper.getAuthor()
    public lazy var wish: Wish = Wish(type: WishType.group.rawValue, status: WishStatus(), location: Location(), date: WishDate(), author: author, showOnMap: false)
    
    public func resetWishModel() {
        self.wish = Wish(type: WishType.group.rawValue, status: WishStatus(), location: Location(), date: WishDate(), author: author, showOnMap: false)
    }
    
    // MARK: - Public Methods
    public func setupUser() {
        DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: DB.Helper.uid)) { (result) in
            switch result {
            case .success(let userVM):
                self.wish.author = Author(uid: userVM.uid,
                                          username: userVM.username,
                                          thumb: userVM.avatar,
                                          gender: userVM.gender,
                                          birthday: userVM.birthday)
            case .failure(let error):
                self.showHUD?(.error, error.localizedDescription)
                self.navigateBack?()
            }
        }
    }
    
    public func create(title: String, description: String, image: UIImage?) {
        self.showHUD?(.loading, "")
        wish.title = title
        wish.description = description
        
        wish.date.publish = Timestamp(date: Date())
        wish.date.update = Timestamp(date: Date())
        wish.top = Top(
            status: true,
            votes: 0)

        createWish(image: image) { [self] (result) in
            switch result {
            case .success(_):
                self.showHUD?(.success, LocalizedText.addWish.WISH_ADDED_SUCCESS)
                self.navigateBack?()
            case .failure(let error): self.showHUD?(.error, error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Methods
    private func createWish(image: UIImage?, completion: @escaping(Result<Bool, Error>) -> Void) {
        self.createWishInFirebase() { (result) in
            switch result {
            case .success(let id):
                
                Ref.Fire.user(uid: DB.Helper.uid).updateData([Ref.User.counters.wishes : FieldValue.increment(Int64(1))])
                self.wish.id = id
                
                DispatchQueue.main.async {
                    if self.wish.type == WishType.group.rawValue {
                        self.createGroupRoom(createdWish: self.wish) { (result) in
                            switch result {
                            case .success(_): completion(.success(true))
                            case .failure(let error): completion(.failure(error))
                            }
                        }
                    }
                    self.saveWishImage(image: image, wishId: id) { (result) in
                        switch result {
                        case .success(let url):
                            self.wish.image = url
                            completion(.success(true))
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helpers
    private func createWishInFirebase(completion: @escaping((Result<String, Error>) -> Void)) {
        let ref = Ref.Fire.wishes.document()
        wish.id = ref.documentID
        
        DB.create(model: wish, ref: ref) { (result) in
            switch result {
            case .success(_): completion(.success(ref.documentID))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    private func saveWishImage(image: UIImage?, wishId: String, completion: @escaping(Result<String?, Error>) -> Void) {
        if let image = image {
            DB.Storage.saveWishImage(image: image, wishId: wishId) { (result) in
                switch result {
                case .success(let url): completion(.success(url))
                case .failure(let error): completion(.failure(error))
                }
            }
        } else {
            completion(.success(nil))
        }
    }
    
    private func createGroupRoom(createdWish: Wish, completion: @escaping(Result<Bool, Error>) -> Void) {
        let ref = Ref.Fire.rooms.document()
        
        let room = Room(
            id: ref.documentID,
            typeIsGroup: true,
            wish: WishInfo(
                id: createdWish.id,
                title: createdWish.title
            ),
            participants: [createdWish.author.uid],
            refused: [],
            users: [
                createdWish.author.uid :
                        RoomUser(
                            uid: createdWish.author.uid,
                            username: createdWish.author.username,
                            thumb: createdWish.author.thumb,
                            read: true, role: "admin"
                        )
            ],
            message: RoomMessage(),
            status: RoomStatus(),
            date: MiniDate(publish: Timestamp(date: Date())))
        
        
        DB.create(model: room, ref: ref) { (result) in
            switch result {
            case .success(let room):
                var createdRoom = room
                createdRoom.id = room.id
                
                Ref.Fire.notify(id: room.id).setData(["id": room.id, "users": [DB.Helper.uid: true]])
                
                if !room.typeIsGroup {
                    DB.Helper.createMessage(roomId: room.id, value: [
                        Ref.Message.text: LocalizedText.addWish.SINGLE_CHAT_CREATED,
                        Ref.Message.type: "info",
                        Ref.Message.date: Date().timeIntervalSince1970 * 1000
                    ])
                } else {
                    DB.Helper.createMessage(roomId: room.id, value: [
                        Ref.Message.text: LocalizedText.addWish.GROUP_CREATED,
                        Ref.Message.type: "info",
                        Ref.Message.date: Date().timeIntervalSince1970 * 1000
                    ])
                }
                completion(.success(true))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
}
