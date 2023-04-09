//
 

import Foundation
import Firebase
import FirebaseFirestore

class RoomSettingsViewModel {
    
    // MARK: - Binding
    var navigateProfile: ((_ uid: String) -> Void)?
    var navigateBanned: ((_ roomVM: RoomViewModel, _ deletedUsers: [RoomUserViewModel]) -> Void)?
    
    // MARK: - Variables
    var roomUpdate: ((_ viewModel: RoomViewModel) -> Void)!
    private var roomListener: ListenerRegistration?
    
    var roomUserViewModels: [RoomUserViewModel] = []
    var deletedRoomUserViewModels: [RoomUserViewModel] = []
    
    // MARK: - LifeCycle
    init() {
    }
    
    // MARK: - Methods
    public func setupUsers(roomVM: RoomViewModel) {
        roomUserViewModels = []
        deletedRoomUserViewModels = []
        
        for user in roomVM.activeUsers {
            let user = RoomUserViewModel(user: user.value, author: roomVM.author)
            if !roomVM.typeIsGroup { user.hideDeleteButton = true }
            roomUserViewModels.append(user)
        }
        if DB.Helper.uid == roomVM.author.uid {
            roomVM.deletedUsers.forEach {
                deletedRoomUserViewModels.append(RoomUserViewModel(user: $0.value, author: roomVM.author))
            }
        }
    }
    
    public func leave() {
        if let roomListener = roomListener {
            roomListener.remove()
        }
    }
    
    func observeRoom(id: String) {
        DB.listenViewModel(model: Room.self, viewModel: RoomViewModel.self, ref: Ref.Fire.room(id: id)) { (result) in
            switch result {
            case .success(let roomVM):
                self.roomUpdate(roomVM)
                self.setupUsers(roomVM: roomVM)
            case .failure(let error): debugPrint(error.localizedDescription)
            }
        } captureListener: { (listener) in
            self.roomListener = listener
        }
    }
    
}
