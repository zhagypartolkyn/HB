 

import Foundation
import UIKit
import FirebaseFirestore

class EditProfileViewModel {
    
    var userVM: UserViewModel?
    var largeAvatar: UIImage?
    
    var initialSetupUser: ((_ userVM: UserViewModel) -> Void)!
    var showHudError: ((_ error: String) -> Void)!
    var showHudSuccess: ((_ text: String) -> Void)!
    
    init() {}
    
    // MARK: - Public
    public func fetchUser() {
        let uid = DB.Helper.uid
        DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: uid)) { (result) in
            switch result {
            case .success(let userVM):
                self.userVM = userVM
                self.initialSetupUser(userVM)
            case .failure(let error):
                self.showHudError(error.localizedDescription)
            }
        }
    }
    
    public func saveUser(name: String, username: String, bio: String) {
        guard let userVM = userVM else {
            showHudError("Your user model not found")
            return
        }
        
        isNeedUpdateUsername(userVM: userVM, username: username) { (status) in
            if status {
                self.updateUserData(userVM: userVM, username: username, name: name, bio: bio)
            } else {
                self.updateUserData(userVM: userVM, name: name, bio: bio)
            }
        }
    }
    
    // MARK: - Private Methods
    private func updateUserData(userVM: UserViewModel, username: String? = nil, name: String, bio: String) {
        
        let batchService = BatchService()
        
        batchService.performBatchOperation { (batch, commit) in
        
            var updateData = [String: Any]()
            
            if let username = username { updateData["username"] = username }
            if userVM.name != name { updateData["name"] = name }
            if userVM.bio != bio { updateData["bio"] = bio }
            
            if !updateData.isEmpty {
                batch.updateData(updateData, forDocument: Ref.Fire.user(uid: userVM.uid))
            }
            
            if let largeAvatar = largeAvatar {
                saveAvatar(largeAvatar: largeAvatar, batch: batch) { (thumbUrl) in
                    self.updateAuthorInfo(username: username, thumb: thumbUrl, batch: batch) { commit() }
                }
            } else {
                if let username = username {
                    self.updateAuthorInfo(username: username, batch: batch) { commit() }
                } else {
                    commit()
                }
            }
        } completionHandler: {
            self.showHudSuccess(LocalizedText.alert.saved)
        }
    }
    
    private func saveAvatar(largeAvatar: UIImage, batch: WriteBatch, completion: @escaping((String) -> Void)) {
        guard let thumbAvatar = largeAvatar.sd_resizedImage(with: CGSize(width: 200, height: 200), scaleMode: .aspectFill) else {
            showHudError("Error with loading image")
            return
        }
        
        DB.Storage.saveAvatar(thumb: thumbAvatar, large: largeAvatar) { [self] (result) in
            switch result {
            case .success((let largeUrl, let thumbUrl)):
                batch.updateData([Ref.User.avatar.large: largeUrl, Ref.User.avatar.thumb: thumbUrl], forDocument: Ref.Fire.user(uid: DB.Helper.uid))
                completion(thumbUrl)
            case .failure(let error):
                showHudError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helpers
    private func isNeedUpdateUsername(userVM: UserViewModel, username: String, completion: @escaping((Bool) -> Void)) {
        if userVM.username != username {
            if !username.isValidUsername {
                showHudError(LocalizedText.alert.usernameUnavailable)
            } else {
                DB.fetchModels(model: User.self, query: Queries.User.username(username)) { (result) in
                    switch result {
                    case .success(_):
                        self.showHudError(LocalizedText.alert.usernameUnavailable)
                    case .failure(_):
                        DB.fetchModels(model: ReservedUsername.self, query: Queries.User.reserverUsername(username)) { [self] (result) in
                            switch result {
                            case .success(_): self.showHudError(LocalizedText.alert.usernameUnavailable)
                            case .failure(_): completion(true)
                            }
                        }
                    }
                }
            }
        } else {
            completion(false)
        }
    }
    
    private func updateAuthorInfo(username: String? = nil, thumb: String? = nil, batch: WriteBatch, completion: @escaping(() -> Void)) {
        let uid = DB.Helper.uid
        
        var updateData: [String: Any] = [:]
        var updateRoomData: [String: Any] = [:]
        
        if let username = username {
            updateData["author.username"] = username
            updateRoomData["users.\(uid).username"] = username
        }
        if let thumb = thumb {
            updateData["author.thumb"] = thumb
            updateRoomData["users.\(uid).thumb"] = thumb
        }
        
        self.updateAuthorInfoHelper(query: Ref.Fire.wishes.whereField(Ref.Wish.author.uid, isEqualTo: uid), data: updateData, batch: batch, completion: {
//            self.updateAuthorInfoHelper(query: Ref.Fire.histories.whereField(Ref.Wish.author.uid, isEqualTo: uid), data: updateData, batch: batch, completion: {
//                self.updateAuthorInfoHelper(query: Ref.Fire.requests.whereField(Ref.Wish.author.uid, isEqualTo: uid), data: updateData, batch: batch, completion: {
//                    self.updateAuthorInfoHelper(query: Ref.Fire.notifications.whereField(Ref.Wish.author.uid, isEqualTo: uid), data: updateData, batch: batch, completion: {
                        self.updateAuthorInfoRoomsHelper(query: Ref.Fire.rooms.whereField("\(Ref.Room.users).\(uid).\(Ref.User.uid)", isEqualTo: uid), data: updateRoomData, batch: batch, completion: {
                            completion()
                        })
//                    })
//                })
//            })
        })
    }
    
    private func updateAuthorInfoHelper(query: Query, data: [String: Any], batch: WriteBatch, completion: @escaping(() -> Void)) {
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                 completion()
                 return
            }
            
            for document in documents {
                batch.updateData(data, forDocument: document.reference)
            }
            completion()
        }
    }
    
    private func updateAuthorInfoRoomsHelper(query: Query, data: [String: Any], batch: WriteBatch, completion: @escaping(() -> Void)) {
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                 completion()
                 return
            }
            
            for document in documents {
                batch.updateData(data, forDocument: document.reference)
            }
            completion()
        }
    }
}
