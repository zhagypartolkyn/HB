 
 

import FirebaseFirestore

class FullWishViewModel {
    
    // MARK: - Binding
    var navigateHistory: ((_ currentIndexPath: IndexPath) -> Void)?
    var navigateAddHistory: ((_ image: UIImage, _ url: URL?, _ wishVM: WishViewModel) -> Void)?
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateRequests: ((_ wishVM: WishViewModel) -> Void)?
    var navigateMessage: ((_ wishId: String) -> Void)?
    var navigateRooms: ((_ wishVM: WishViewModel) -> Void)?
    var navigateReport: ((_ reportObject: ReportObject) -> Void)?
    var navigateComplete: ((_ wishVM: WishViewModel) -> Void)?
    
    // MARK: - Variables
    var wishVM: WishViewModel!
    var roomVM: RoomViewModel?
    var wishId: String?
    var wishUpdate: ((_ vm: WishViewModel) -> Void)?
    var roomUpdate: ((_ vm: RoomViewModel) -> Void)?
    
    // MARK: - LifeCycle
    init(wishVM: WishViewModel? = nil, wishId: String? = nil) {
        self.wishVM = wishVM
        self.wishId = wishId
    }
    
    func fetchWish() {
        if let wishVM = wishVM {
            fetchRoom(wishVM: wishVM)
        } else if let wishId = wishId {
            DB.fetchViewModel(model: Wish.self, viewModel: WishViewModel.self, ref: Ref.Fire.wish(id: wishId)) { (result) in
                switch result {
                case .success(let wishVM):
                    DispatchQueue.main.async { [self] in
                        self.wishVM = wishVM
                        self.fetchRoom(wishVM: wishVM)
                    }
                    
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    func fetchRoom(wishVM: WishViewModel) {
        if !wishVM.isGroupWish {
            wishUpdate?(wishVM)
        } else {
            DB.fetchViewModels(model: Room.self, viewModel: RoomViewModel.self, query: Queries.Room.wish(id: wishVM.id)) { (result) in
                switch result {
                case .success((let roomVMs, _, _)):
                if let roomVM = roomVMs.first {
                    self.roomVM = roomVM
                    self.roomUpdate?(roomVM)
                }
                self.wishUpdate?(self.wishVM)
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    func createRequest(text: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let wishVM = wishVM else { return }
        
        DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: DB.Helper.uid)) { (result) in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let userVM):
                let refRequests = Ref.Fire.requests.document()
                let request = Request(id: refRequests.documentID,
                                      wish: WishInfo(id: wishVM.id, title: wishVM.title),
                                      author: Author(uid: userVM.uid, username: userVM.username, thumb: userVM.avatar, gender: userVM.gender, birthday: userVM.birthday),
                                      status: StatusRequest(),
                                      date: MiniDate(publish: Timestamp(date: Date())),
                                      text: text,
                                      to: wishVM.author.uid)
                
                DB.create(model: request, ref: refRequests) { (result) in
                    switch result {
                    case .success(let request):
                        Ref.Fire.wish(id: request.wish.id!).updateData([Ref.Wish.status.request: true])
                        
                        DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: DB.Helper.uid)) { (result) in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(let userVM):
                                
                                let refNotification = Ref.Fire.notifications.document()
                                
                                let notification = Activity(
                                    id: refNotification.documentID,
                                    type: "request", to: wishVM.author.uid,
                                    author: Author(uid: userVM.uid, username: userVM.username, thumb: userVM.avatar, gender: userVM.gender, birthday: userVM.birthday),
                                    wish: request.wish,
                                    status: NewsStatus(), date: MiniDate(publish: Timestamp(date: Date()))
                                )
                                
                                DB.create(model: notification, ref: refNotification) { (_) in }
                                
                                sendRequestNotification(toUid: wishVM.author.uid,
                                                        title: "Запрос на ваше желание",
                                                        subtitle: wishVM.title,
                                                        type: "request",
                                                        linkId: wishVM.id,
                                                        badge: 1)
                                completion(.success(true))
                            }
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
}
