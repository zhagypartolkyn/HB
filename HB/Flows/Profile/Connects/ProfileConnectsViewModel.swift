 

import Foundation

class ProfileConnectsViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    
    var connectsIds = [String]()
    var completedWishesAssociation = [String: Int]()
    let uid: String
    var reloadData: (() -> Void)!
    var batchSize = 15
    var currentBatchIndex = 0
    var loadedConnects = [UserViewModel]()
    var lastPage = false
    var performingRequest = false
    var isHidden = false
    
    func loadUsers() {
        performingRequest = true
        var subArray: [String]
        if currentBatchIndex + batchSize < connectsIds.count {
            subArray = Array(connectsIds[currentBatchIndex ..< currentBatchIndex + batchSize])
        } else {
            subArray = Array(connectsIds[currentBatchIndex ..< connectsIds.count])
            lastPage = true
        }
        let endingConstant = loadedConnects.count + subArray.count
        for connectId in subArray {
            
            DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: connectId)) { [self] (result) in
                switch result {
                case .success(let userVM):
                    loadedConnects.append(userVM)
                    if loadedConnects.count == endingConstant {
                        currentBatchIndex += batchSize
                        performingRequest = false
                        reloadData()
                    }
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    func getConnects() {
        DB.fetchModel(model: Connects.self, ref: Ref.Fire.connect(uid: uid)) { [self] (result) in
            switch result {
            case .success(let connects):
                for connect in connects.connects {
                    if let completedWish = completedWishesAssociation[connect.uid] {
                        completedWishesAssociation[connect.uid] = completedWish + 1
                    } else {
                        connectsIds.append(connect.uid)
                        completedWishesAssociation[connect.uid] = 1
                    }
                }
                self.loadUsers()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    init(uid: String) {
        self.uid = uid
    }
}
