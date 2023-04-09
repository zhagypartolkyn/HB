 

import Foundation
import FirebaseFirestore

class RequestViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateMessage: ((_ wishId: String?, _ roomId: String?) -> Void)?
    
    
    var setupTableView: (() -> Void)?
    var reloadData: (() -> Void)?
    var setupWishTitle: ((_ title: String) -> Void)?
    var setupNavigationTitle: ((_ title: String) -> Void)?
    var setupErroView: ((_ isCompleted: Bool) -> Void)?
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    
    // MARK: - Variables
    public var wishVM: WishViewModel?
    public var requests = [Request]()
    public var requestsInDateSection = [[Request]]()
    
    // MARK: - LifeCycle
    init() {
        
    }
    
    // MARK: - Public Methods
    public func configure(wishVM: WishViewModel? = nil, wishId: String? = nil) {
        if let wishId = wishId {
            DB.fetchViewModel(model: Wish.self, viewModel: WishViewModel.self, ref: Ref.Fire.wish(id: wishId)) { (result) in
                switch result {
                case .success(let wishVM):
                    self.wishVM = wishVM
                    self.fetchRequests(wishVM: wishVM)
                case .failure(let error):
                    debugPrint(error)
                }
            }
        } else if let wishVM = wishVM {
            self.wishVM = wishVM
            fetchRequests(wishVM: wishVM)
        }
    }
    
    public func divideRequestsByDate(wishVM: WishViewModel) {
        setupNavigationTitle?("\(LocalizedText.wish.requests.REQUESTS) (\(requests.count))")
        
        if requests.isEmpty  {
            Ref.Fire.wish(id: wishVM.id).updateData([Ref.Wish.status.request : false])
            requestsInDateSection = [[Request]]()
            setupErroView?(false)
            return
        }
        
        let groupedMessages = Dictionary(grouping: requests) { (element) -> Date in
            let dateString = element.date.publish?.dateValue().toFormat("MM/dd/yyyy")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            return dateFormatter.date(from: dateString!)!
        }
        
        
        let sortedKeys = groupedMessages.keys.sorted()
        requestsInDateSection = [[Request]]()
        
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key] ?? []
            requestsInDateSection.append(values)
            reloadData?()
        }
    }
    
    public func acceptToGroup(request: Request, completionHandler: @escaping (() -> Void)) {
        guard let wishVM = wishVM else { return }
        DB.fetchViewModels(model: Room.self, viewModel: RoomViewModel.self, query: Queries.Room.wish(id: wishVM.id), completion: { (result) in
            switch result {
            case .success((let roomVMs, _, _)):
                let roomVM = roomVMs[0]

                roomVM.allUsers.updateValue(
                    RoomUser(uid: request.author.uid, username: request.author.username, thumb: request.author.thumb, read: false, role: "normal"),
                    forKey: request.author.uid)

                DB.Helper.updateRoomUser(roomId: roomVM.id, wishId: roomVM.wishId, uid: request.author.uid, request: request, users: roomVM.allUsers, isDeleted: false, completionHandler: {
                    Ref.Fire.notify(id: roomVM.id).updateData(["users.\(request.author.uid)" : true])

                    DB.Helper.createMessage(roomId: roomVM.id, value: [
                        Ref.Message.text: "\(request.author.username) \(LocalizedText.wish.requests.ADDED)",
                        Ref.Message.type: "info",
                        Ref.Message.uid: request.author.uid,
                        Ref.Message.date: Date().timeIntervalSince1970 * 1000,
                        Ref.Message.imageUrl: request.author.thumb
                    ])
                    self.requests.removeAll(where: { $0.id == request.id })
                    self.divideRequestsByDate(wishVM: wishVM)
                    completionHandler()
                })

            case .failure(let error):
                debugPrint(error)
            }
        })
        
    }
    
    public func acceptToSingle(request: Request, completionHandler: @escaping (_ roomId: String) -> Void) {
        guard let wishVM = wishVM else { return }

        let ref = Ref.Fire.rooms.document()
        
        let room = Room(id: ref.documentID,
                        typeIsGroup: false,
                        wish: WishInfo(id: wishVM.id, title: wishVM.title),
                        participants: [request.author.uid, wishVM.author.uid], refused: [],
                        users: [
                            request.author.uid : RoomUser(uid: request.author.uid, username: request.author.username, thumb: request.author.thumb, read: false, role: "normal"),
                            wishVM.author.uid : RoomUser(uid: wishVM.author.uid, username: wishVM.author.username, thumb: wishVM.author.thumb, read: true, role: "admin")],
                        message: RoomMessage(),
                        status: RoomStatus(),
                        date: MiniDate(publish: Timestamp(date: Date())))

        DB.create(model: room, ref: ref) { [self] (result) in
            switch result {
            case .success(let room):
                Ref.Fire.notify(id: room.id).setData(["id": room.id, "users": [DB.Helper.uid: true]])

            
                Ref.Fire.notify(id: room.id).updateData(["users.\(request.author.uid)" : true])
                       
                var createdRoom = room
                createdRoom.id = room.id
                let roomVM = RoomViewModel(value: createdRoom)
                
                self.showHUD?(.success, LocalizedText.wish.requests.CONFIRM_REQUEST_HUD)
                Ref.Fire.wish(id: roomVM.wishId).updateData(["participants" : FieldValue.arrayUnion([request.author.uid])])
                Ref.Fire.request(id: request.id).updateData([Ref.Request.status.accept: true])
                DB.Helper.createMessage(roomId: roomVM.id, value: [
                    Ref.Message.text: LocalizedText.wish.requests.CHAT_CREATED,
                    Ref.Message.type: "info",
                    Ref.Message.uid: request.author.uid ,
                    Ref.Message.date: Date().timeIntervalSince1970 * 1000,
                    Ref.Message.imageUrl: request.author.thumb
                ])
                if let text = request.text, text.count > 0 {
                    DB.Helper.createMessage(roomId: roomVM.id, value: [
                        Ref.Message.text: text,
                        Ref.Message.type: "info",
                        Ref.Message.date: Date().timeIntervalSince1970 * 1000
                    ])
                }

                self.requests.removeAll(where: { $0.id == request.id })
                self.divideRequestsByDate(wishVM: wishVM)
                completionHandler(roomVM.id)

            case .failure(let error):
                self.showHUD?(.error, error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Methods
    private func fetchRequests(wishVM: WishViewModel) {
        DB.fetchModels(model: Request.self, query: Queries.Request.fetch(wishId: wishVM.id)) { (result) in
            self.setupWishTitle?(wishVM.title)
            switch result {
            case .success((let models, _, _)):
                self.setupTableView?()
                self.requests.append(contentsOf: models)
                self.divideRequestsByDate(wishVM: wishVM)
            case .failure(_):
                self.setupErroView?(wishVM.isComplete)
            }
        }
    }
    
}
