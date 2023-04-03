 

import UIKit
import FirebaseFirestore

class SignUpViewModel {
    // MARK: - Binding
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    var navigateRoot: (() -> Void)?
    
    // MARK: - Variables
    let batchService = BatchService()
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    // MARK: - Public Methods
    func signUpAction(largeAvatar: UIImage, thumbAvatar: UIImage, username: String, gender: String, birthday: Timestamp) {
        showHUD?(.loading, "")
        isUsernameAvailable(username: username) { [self] in
            saveUser(username: username, gender: gender, birthday: birthday) {
                saveAvatar(largeAvatar: largeAvatar, thumbAvatar: thumbAvatar) {
                    DB.Helper.isOnline(bool: true)
                    self.showHUD?(.dismiss, "")
                    self.navigateRoot?()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func isUsernameAvailable(username: String, completionHandler: @escaping (() -> Void)) {
        DB.fetchModels(model: User.self, query: Queries.User.username(username)) { [self] (result) in
            switch result {
            case .success(_):
                self.showHUD?(.error, LocalizedText.alert.usernameUnavailable)
            case .failure(_):
                DB.fetchModels(model: ReservedUsername.self, query: Queries.User.reserverUsername(username)) { [self] (result) in
                    switch result {
                    case .success(_): self.showHUD?(.error, LocalizedText.alert.usernameUnavailable)
                    case .failure(_): completionHandler()
                    }
                }
            }
        }
    }
    
    private func saveUser(username: String, gender: String, birthday: Timestamp, completionHandler: @escaping (() -> Void)) {
        guard let uid = user.uid else { return }
        
        user.username = username
        user.gender = gender
        user.birthday = birthday
        user.status.correct = true

        self.batchService.performBatchOperation(operation: { (batch, commit) in
            try batch.setData(from: user, forDocument: Ref.Fire.user(uid: uid))
            try batch.setData(from: Connects(uid: uid), forDocument: Ref.Fire.connect(uid: uid))
            commit()
        }, completionHandler: {
            completionHandler()
        }, onError: { error in
            self.showHUD?(.error, error.localizedDescription)
        })
    }
    
    private func saveAvatar(largeAvatar: UIImage, thumbAvatar: UIImage, completionHandler: @escaping (() -> Void)) {
        DB.Storage.saveAvatar(thumb: thumbAvatar, large: largeAvatar) { (result) in
            switch result {
            case .success((let largeUrl, let thumbUrl)):
                
                Ref.Fire.user(uid: DB.Helper.uid).updateData([
                    Ref.User.avatar.large: largeUrl,
                    Ref.User.avatar.thumb: thumbUrl
                ]) { (error) in
                    if let error = error {
                        self.showHUD?(.error, error.localizedDescription)
                        return
                    }
                    completionHandler()
                }
            case .failure(let error): self.showHUD?(.error, error.localizedDescription)
            }
        }
    }
}
