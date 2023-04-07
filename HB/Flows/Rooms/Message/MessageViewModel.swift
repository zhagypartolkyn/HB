 

import Foundation
import MessageKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

class MessageViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateWish: ((_ wishVM: WishViewModel?, _ wishId: String?) -> Void)?
    var navigateRoomSettings: ((_ roomVM: RoomViewModel, _ myNotifyStatus: Bool) -> Void)?
    
    // MARK: - Variables
    var setupAvatarAndWishTitle: ((_ viewModel: RoomViewModel) -> Void)!
    var setupNavigation: ((_ title: String, _ subtitle: String) -> Void)!
    var reloadDataCallbackAndScrollDown: (() -> Void)!
    var reloadDataCallbackAndSaveOffset: (() -> Void)!
    var endRefreshing: (() -> Void)!
    var quitFromController: (() -> Void)!
    var showHudError: ((_ title: String) -> Void)!
    
    var myNotifyStatus: Bool = true
    var messages: [Message] = []
    var roomViewModel: RoomViewModel?
    
    private var notifyUsers: [String] = []
    private var lastMessageKey: String?
    private var roomListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    private var notifyListener: ListenerRegistration?
    
    
    // MARK: - LifeCycle
    init() {}
    
    // MARK: - Public Methods
    public func configure(wishId: String? = nil, roomId: String? = nil) {
        if let wishId = wishId {
            DB.fetchViewModels(model: Room.self, viewModel: RoomViewModel.self, query: Queries.Room.myWithWish(id: wishId)) { (result) in
                switch result {
                case .success((let roomVMs, _, _)):
                    if let roomVM = roomVMs.first {
                        self.listenRoomBy(id: roomVM.id)
                    }
                case .failure(let error): self.showHudError(error.localizedDescription)
                }
            }
        }
        
        if let roomId = roomId {
            listenRoomBy(id: roomId)
        }
    }
    
    private func listenRoomBy(id: String) {
        DB.listenViewModel(model: Room.self, viewModel: RoomViewModel.self, ref: Ref.Fire.room(id: id)) { (result) in
            switch result {
            case .success(let roomVM): self.configureRoomHelper(roomVM: roomVM)
            case .failure(let error): self.showHudError(error.localizedDescription)
            }
        } captureListener: { (listener) in
            self.roomListener = listener
        }
    }
    
    public func loadMoreMessages() {
        guard let lastMessageKey = lastMessageKey, let roomVM = roomViewModel else { return }
        
        self.fetchMoreMessages(id: roomVM.id, lastMessageKey: lastMessageKey, limit: 30) { [self] (messagesArray, lastMessageKey) in
            if messagesArray.isEmpty {
                self.endRefreshing()
                return
            }
            
            messagesArray.forEach { (message) in
                message.username = self.roomViewModel?.allUsers[message.uid]?.username ?? "Username not found"
            }
            
            self.messages = messagesArray + self.messages
            self.lastMessageKey = lastMessageKey
            self.reloadDataCallbackAndSaveOffset()
            self.endRefreshing()
        }
    }
    
    public func sendMessage(text: String) {
        guard let roomVM = roomViewModel else { return }
        createMessageHelper(roomId: roomVM.id, type: "text", text: text)
        sendPushNotification(roomVM: roomVM, message: text)
    }
    
    public func sendMessage(image: UIImage) {
        guard let roomVM = roomViewModel,
              let resizedImage = image.sd_resizedImage(with: CGSize(width: 1080, height: 1080), scaleMode: .aspectFill),
              let compressedImage = resizedImage.jpegData(compressionQuality: 0.4) else { return }
        
        let storageRefPhoto = Ref.Store.message(roomId: roomVM.id, name: UUID().uuidString, isVideo: true)
        
        savePhotoHelper(imageData: compressedImage, storageRef: storageRefPhoto) { (imageUrl) in
            self.createMessageHelper(roomId: roomVM.id, type: "image", text: "фото", imageUrl: imageUrl)
            self.sendPushNotification(roomVM: roomVM, message: "отправил фото")
        }
    }
    
    public func sendMessage(video url: URL) {
        guard let roomVM = roomViewModel,
              let thumbnail = DB.Storage.thumbnailImageForFileUrl(url),
              let compressedImage = thumbnail.jpegData(compressionQuality: 0.4) else { return }
        
        let storageRefVideo = Ref.Store.message(roomId: roomVM.id, name: UUID().uuidString, isVideo: true)
        let storageRefPhoto = Ref.Store.message(roomId: roomVM.id, name: UUID().uuidString, isVideo: false)
        
        savePhotoHelper(imageData: compressedImage, storageRef: storageRefPhoto) { (imageUrl) in
            self.saveVideoHelper(url: url, storageRef: storageRefVideo) { (videoUrl) in
                self.createMessageHelper(roomId: roomVM.id, type: "video", text: "видео", imageUrl: imageUrl, videoUrl: videoUrl)
                self.sendPushNotification(roomVM: roomVM, message: "отправил видео")
            }
        }
    }
    
    public func delete(message: MessageType) {
        guard let roomVM = roomViewModel else { return }
        
        Ref.Real.chat(id: roomVM.id).child(message.messageId).removeValue()
        if let last = messages.last, last.id == message.messageId {
            messages.removeLast()
            guard let newLastMessages = messages.last else { return }
            
            Ref.Fire.room(id: roomVM.id).updateData([
                Ref.Room.message.text: newLastMessages.text as Any,
                Ref.Room.message.type: newLastMessages.type as Any,
                Ref.Room.message.date: Timestamp(date: Date(timeIntervalSince1970: newLastMessages.date / 1000))
            ])
        } else {
            messages.removeAll { $0.messageId == message.messageId }
        }
    }
    
    public func leave() {
        if let userListener = userListener {
            userListener.remove()
        }
        if let roomListener = roomListener {
            roomListener.remove()
        }
        if let notifyListener = notifyListener {
            notifyListener.remove()
        }
        changeStatusOfLastMessageToRead()
    }
    
    // MARK: - Private Methods
    private func observePartner(uid: String) {
        DB.listenViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: uid)) { (result) in
            switch result {
            case .success(let userVM): self.setupNavigationByWithType(userVM: userVM)
            case .failure(let error): self.showHudError(error.localizedDescription)
            }
        } captureListener: { (listener) in
            self.userListener = listener
        }
    }
    
    private func observeMessages(roomVM: RoomViewModel) {
        self.fetchMessages(roomId: roomVM.id, limit: 30) { [self] (message) in
            message.username = roomVM.allUsers[message.uid]?.username ?? "Username not found"
            print(messages.count)
            print("\(message.text) \(message.username)")
            self.messages.append(message)
            print(messages.count)
            print("---------")
            
            self.lastMessageKey = self.messages.first!.id
            self.reloadDataCallbackAndScrollDown()
        }
    }
    
    private func observeNotifies(roomVM: RoomViewModel) {
        DB.listenModel(model: RoomNotify.self, ref: Ref.Fire.notify(id: roomVM.id)) { (result) in
            switch result {
            case .success(let model):
                var usersUID: [String] = []
                model.users.forEach({ (uid, isNotify) in
                    if uid == DB.Helper.uid {
                        self.myNotifyStatus = isNotify
                    }
                    
                    if isNotify && uid != DB.Helper.uid {
                        usersUID.append(uid)
                    }
                })
                self.notifyUsers = usersUID
            case .failure(let error):
                self.showHudError(error.localizedDescription)
            }
        } captureListener: { (listener) in
            self.notifyListener = listener
        }
    }
    
    // MARK: - Helper Methods
    private func configureRoomHelper(roomVM: RoomViewModel) {
        if roomViewModel == nil {
            if !roomVM.typeIsGroup { observePartner(uid: roomVM.partnerUid) }
            setupAvatarAndWishTitle(roomVM)
            observeNotifies(roomVM: roomVM)
            observeMessages(roomVM: roomVM)
        }
        
        setupNavigationByWithType(roomVM: roomVM)
        
        if !roomVM.participants.contains(DB.Helper.uid) {
            self.quitFromController()
            return
        }
        
        self.roomViewModel = roomVM
    }
    
    private func setupNavigationByWithType(roomVM: RoomViewModel? = nil, userVM: UserViewModel? = nil) {
        if let userVM = userVM {
            self.setupNavigation(userVM.username, userVM.isOnline ? LocalizedText.messages.ONLINE : LocalizedText.messages.OFFLINE)
        }
        
        if let roomVM = roomVM {
            var onlineText = ""
            if roomVM.onlineUsers.count > 0 {
                onlineText = " , \(roomVM.onlineUsers.count) \(LocalizedText.messages.ONLINE)"
            }
            let title = roomVM.wishTitle.count > 23 ? "\(String(roomVM.wishTitle.prefix(23)))..." : roomVM.wishTitle
            setupNavigation(title, "\(LocalizedText.messages.PARTICIPANTS) \(roomVM.activeUsers.count) \(onlineText)")
        }
    }
    
    private func fetchMessages(roomId: String, limit: Int, onSuccess: @escaping(Message) -> Void) {
        Ref.Real.chat(id: roomId)
            .queryOrderedByKey()
            .queryLimited(toLast: UInt(limit))
            .observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any], let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                
                if let last = self.messages.last, last.sentDate > message.sentDate {
                    let messageDate = message.sentDate
                    let firstDate = message.sentDate
                    print("first \(last.text): \(firstDate.toString()), message \(message.text): \(messageDate.toString())")
                } else {
                    onSuccess(message)
                }
            }
        }
    }
    
    private func fetchMoreMessages(id: String, lastMessageKey: String, limit: Int, onSuccess: @escaping([Message], String) -> Void) {
        Ref.Real.chat(id: id)
            .queryOrderedByKey()
            .queryEnding(atValue: lastMessageKey)
            .queryLimited(toLast: UInt(limit))
            .observeSingleEvent(of: .value) { (snapshot) in
                
            guard let lastMessage = snapshot.children.allObjects.first as? DataSnapshot,
                  let allMessages = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
            var messages = [Message]()
            
            allMessages.forEach({ (object) in
                if object.key == lastMessageKey { return }
                if let dict = object.value as? [String: Any], let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                    messages.append(message)
                }
            })
            onSuccess(messages, lastMessage.key)
        }
    }
    
    private func sendPushNotification(roomVM: RoomViewModel, message: String) {
        for roomUser in roomVM.activeUsers.values {
            guard let uid = roomUser.uid else { return }
            if self.notifyUsers.contains(uid), uid != DB.Helper.uid {
                sendRequestNotification(
                    toUid: uid,
                    title: roomVM.wishTitle,
                    subtitle: "\(DB.Helper.username): \(message)",
                    type: "chat",
                    linkId: roomVM.id,
                    badge: 1)
            }
        }
    }
    
    private func createMessageHelper(roomId: String, type: String, text: String? = nil, imageUrl: String? = nil, videoUrl: String? = nil) {
        var data: [String: Any] = [ Ref.Message.type: type,
                                    Ref.Message.uid: DB.Helper.uid,
                                    Ref.Message.date: Date().timeIntervalSince1970 * 1000 ]
        
        if let text = text { data[Ref.Message.text] = text.trimmingCharacters(in: .whitespacesAndNewlines) }
        if let imageUrl = imageUrl { data[Ref.Message.imageUrl] = imageUrl }
        if let videoUrl = videoUrl { data[Ref.Message.videoUrl] = videoUrl }
        
        DB.Helper.createMessage(roomId: roomId, value: data)
    }
    
    private func savePhotoHelper(imageData: Data, storageRef: StorageReference, completion: @escaping((String) -> Void)) {
        DB.Storage.savePhoto(imageData: imageData, storageRef: storageRef) { (result) in
            switch result {
            case .success(let imageUrl): completion(imageUrl)
            case .failure(let error): self.showHudError(error.localizedDescription)
            }
        }
    }
    
    private func saveVideoHelper(url: URL, storageRef: StorageReference, completion: @escaping((String) -> Void)) {
        DB.Storage.saveVideo(url: url, storageRef: storageRef) { (result) in
            switch result {
            case .success(let videoUrl): completion(videoUrl)
            case .failure(let error): self.showHudError(error.localizedDescription)
            }
        }
    }
    
    private func changeStatusOfLastMessageToRead() {
        guard let roomVM = roomViewModel else { return }
        DB.fetchViewModel(model: Room.self, viewModel: RoomViewModel.self, ref: Ref.Fire.room(id: roomVM.id)) { (result) in
            switch result {
            case .success(let roomVM):
                var usersWhereIRead: [String: RoomUser] = [:]
                for user in roomVM.allUsers {
                    var roomUser = user.value
                    roomUser.read = roomUser.uid == DB.Helper.uid ? true : roomUser.read
                    usersWhereIRead[user.key] = roomUser
                }
                do {
                    try Ref.Fire.room(id: roomVM.id).setData(from: ["users": usersWhereIRead], mergeFields: ["users"])
                } catch {
                    debugPrint(error)
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
}
