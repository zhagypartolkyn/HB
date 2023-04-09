 

import Foundation
import FirebaseFirestore

class ProfileViewModel {
    
    // MARK: - Binding
    var navigateActivities: (() -> Void)?
    var navigateConnects: ((_ uid: String) -> Void)?
    var navigateMedia: ((_ imageUrl: String) -> Void)?
    var navigateEditProfile: (() -> Void)?
    var navigateFollow: ((_ userVM: UserViewModel, _ isFollowing: Bool) -> Void)?
    var navigateWish: ((_ wishVM: WishViewModel?, _ wishId: String?) -> Void)?
    var navigateReport: ((_ reportObject: ReportObject) -> Void)?
    var navigateSettings: (() -> Void)?
    var navigateRoot: (() -> Void)?
    var navigateComplete: ((_ wishVM: WishViewModel) -> Void)?
    var navigateBack: (() -> Void)?
    
    // MARK: - Variabels
    var uid: String!
    var isMyProfile = true
    var batchSize: Int
    var increasingConstant: Int
    
    var reloadDataCallback: (() -> Void)!
    
    // MARK: - LifeCycle
    init(uid: String) {
        self.batchSize = 15
        self.increasingConstant = batchSize
        
        self.uid = uid
        self.isMyProfile = uid == DB.Helper.uid
    }
    
    
    
    // MARK: - ==============================
    // MARK: - UNREAD NOTIFICATIONS
    // MARK: - ==============================
    
    var changeUnredNotifications: ((Int) -> Void)?
    
    func listenUnreadNotifications() {
        if !isMyProfile { return }
        
        DB.listenModels(model: Activity.self, query: Queries.Notification.unreads()) { [self] (result) in
            print("listenModels")
            switch result {
            case .success((let viewModels, _)): changeUnredNotifications?(viewModels.count)
            case .failure(_): changeUnredNotifications?(0)
            }
        } captureListener: { (listener) in
            
        }
    }
    
    // MARK: - Public Methods
    var userVM: UserViewModel?
    var userListener: ListenerRegistration?
    var isFollowing: Bool?
    var connectsCount: Int?
    var topConnects: [ComparableConnect] = []
    
    var usernameForTitle: ((String, Bool) -> Void)!
    
    public func configureVM() {
        if let userVM = userVM {
            usernameForTitle(userVM.username, userVM.verified)
        } else {
            getWishes(.active)

            observeUser { [self] (viewModel) in
                checkBlockedStatus(uid: viewModel.uid) {
                    usernameForTitle(viewModel.username, viewModel.verified)
                    userVM = viewModel
                    checkFollow(userVM: viewModel) { (status) in
                        isFollowing = status
                        reloadDataCallback()
                    }
                }
            }

            observeConnects { [self] (connects) in
                connectsCount = connects.connects.count
                if connects.connects.count >= 6 {
                    getConnectsWithImage(connects: connects) { (sortedConnects) in
                        topConnects = sortedConnects
                        reloadDataCallback()
                    }
                }
            }
        }
    }
    
    private func checkBlockedStatus(uid: String, completion: @escaping(() -> Void)) {
        DB.fetchModels(model: BlockedUser.self, query: Queries.BlockedUser.checkIfIBlocked(uid: uid, myUid: DB.Helper.uid)) { (result) in
            switch result {
            case .success(_): self.navigateBack?()
            case .failure(_): completion()
            }
        }
    }
    
    private func observeUser(completion: @escaping((UserViewModel) -> Void)) {
        DB.listenViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: uid)) { (result) in
            switch result {
            case .success(let userVM): completion(userVM)
            case .failure(let error): debugPrint(error)
            }
        } captureListener: { (listener) in
            self.userListener = listener
        }
    }
    
    private func checkFollow(userVM: UserViewModel, completion: @escaping((Bool) -> Void)) {
        if !userVM.isMe, self.isFollowing == nil {
            DB.fetchModels(model: User.self, query: Queries.Follow.check(uid: userVM.uid)) { (result) in
                switch result {
                case .success(_): completion(true)
                case .failure(_): completion(false)
                }
            }
        } else {
            reloadDataCallback()
        }
    }
    
    private func observeConnects(completion: @escaping((Connects) -> Void)) {
        DB.listenModel(model: Connects.self, ref: Ref.Fire.connect(uid: uid)) { (result) in
            switch result {
            case .success(let model): completion(model)
            case .failure(let error): debugPrint(error)
            }
        } captureListener: { (listener) in
            // Delete Listener
        }
    }
    
    private func getConnectsWithImage(connects: Connects, completion: @escaping(([ComparableConnect]) -> Void)) {
        var sortedConnects: [ComparableConnect] = []
        
        let myGroup = DispatchGroup()
        getTopConnectedUsers(connects: connects) { (topConnectsUid) in
            for (index, uid) in topConnectsUid.enumerated() {
                myGroup.enter()
                DB.fetchModel(model: User.self, ref: Ref.Fire.user(uid: uid)) { (result) in
                    switch result {
                    case .success(let user):
                        sortedConnects.append(ComparableConnect(imageURL: user.avatar.thumb ?? "", importanceOrder: index))
                        myGroup.leave()
                    case .failure(let error):
                        debugPrint(error)
                        myGroup.leave()
                    }
                }
            }
            
            myGroup.notify(queue: .main) {
                completion(sortedConnects.sorted())
            }
        }
    }
    
    private func getTopConnectedUsers(connects: Connects, completion: @escaping(([String]) -> Void)) {
        // Count dublicate connects by uid
        var countConnectDublicates = [String: Int]()
        for connect in connects.connects {
            if let existingConnect = countConnectDublicates[connect.uid] {
                countConnectDublicates[connect.uid] = existingConnect + 1
            } else {
                countConnectDublicates[connect.uid] = 1
            }
        }
        
        var topConnectsUid: [String] = []
        var uniqueConnectsUid = Array(countConnectDublicates.keys)
        let numberOfConnectsToDisplay = uniqueConnectsUid.count < 7 ? uniqueConnectsUid.count : 7
        
        for _ in 0..<numberOfConnectsToDisplay {
            var maxConnectsNumber = 0
            var maxIndex = 0
            
            for (index, uid) in uniqueConnectsUid.enumerated() {
                if let count = countConnectDublicates[uid], count > maxConnectsNumber {
                    maxConnectsNumber = count
                    maxIndex = index
                }
            }
            
            topConnectsUid.append(uniqueConnectsUid[maxIndex])
            uniqueConnectsUid.remove(at: maxIndex)
            if uniqueConnectsUid.isEmpty { break }
        }
        
        completion(topConnectsUid)
    }
    
    // Handle Follow
    let batchService = BatchService()
    var isDisableFollowButton: Bool?
    
    func handleFollow() {
        if let user = userVM, !user.isMe, let followStatus = isFollowing {
            disableFollowButton(true)
            
            batchService.performBatchOperation(operation: { [self] (batch, commit) in
                if followStatus {
                    DB.Helper.stopFollow(otherUserUid: user.uid, batch: batch) { (result) in
                        switch result {
                        case .failure(_): disableFollowButton()
                        case .success:
                            isFollowing = false
                            commit()
                            disableFollowButton()
                        }
                    }
                } else {
                    DB.Helper.startFollow(otherUserUid: user.uid, batch: batch) { (res) in
                        switch res {
                        case .failure(_): disableFollowButton()
                        case .success:
                            isFollowing = true
                            sendFollowNotification(uid: user.uid)
                            commit()
                            disableFollowButton()
                        }
                    }
                }
            }, completionHandler: nil)
        }
    }
    
    private func sendFollowNotification(uid: String) {
        sendRequestNotification(
            toUid: uid,
            title: DB.Helper.username,
            subtitle: LocalizedText.notifications.sendFollowNotification,
            type: "follow",
            linkId: DB.Helper.uid,
            badge: 1
        )
    }
    
    private func disableFollowButton(_ status: Bool = false) {
        isDisableFollowButton = status
        reloadDataCallback()
    }
    
    // Wishes
    var isPerformingRequest = false
    var showSkeleton: (() -> Void)!
    var hideSkeleton: (() -> Void)!

    var activeSegmentIndex: IndexCase = .active
    var displayWishes = [WishViewModel]()
    var wishes: [IndexCase: [WishViewModel]] = [.active: [], .completed: [], .participant: []]
    var listeners: [IndexCase: ListenerRegistration?] = [.active: nil, .completed: nil, .participant: nil]
    var isVisited: [IndexCase: Bool] = [.active: false, .completed: false, .participant: false]
    var isLastPage: [IndexCase: Bool] = [.active: false, .completed: false, .participant:false]
    
    func getWishes(_ index: IndexCase) {
        let queries: [IndexCase: Query] = [.active: Queries.Wish.user(uid: uid!, completed: false, limit: batchSize),
                                           .completed: Queries.Wish.user(uid: uid!, completed: true, limit: batchSize),
                                           .participant: Queries.Wish.participant(uid: uid!, limit: batchSize)]
        
        if !isVisited[index]! { showSkeleton() }
        isPerformingRequest = true

        DB.listenViewModels(model: Wish.self, viewModel: WishViewModel.self, query: queries[index]!) { [self] (result) in
            switch result {
            case .success((let viewModels, _, _)):
                wishes[index] = viewModels
                if activeSegmentIndex == index { displayWishes = wishes[index]! } else {displayWishes = []}
                if viewModels.count < batchSize { isLastPage[index] = true }
                reloadDataCallback()
                hideSkeleton()
                isVisited[index] = true
                isPerformingRequest = false
                batchSize += self.increasingConstant
            case .failure(let error):
                debugPrint(error)
                displayWishes = []
                isLastPage[index] = true
                reloadDataCallback()
                hideSkeleton()
                isVisited[index] = true
                isPerformingRequest = false
            }
        } captureListener: { [self] (listener) in
            listeners[index]??.remove()
            listeners[index] = listener
        }
    }
    
}

enum IndexCase {
    case active, completed, participant
}

// Helper struct to sort connects
struct ComparableConnect: Comparable {
    
    static func < (lhs: ComparableConnect, rhs: ComparableConnect) -> Bool {
        return lhs.importanceOrder < rhs.importanceOrder
    }
    var imageURL: String
    var importanceOrder: Int
}
