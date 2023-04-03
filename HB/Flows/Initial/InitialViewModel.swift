

import Foundation
import FirebaseAuth
import FirebaseMessaging

class InitialViewModel {

    // MARK: - Variables
    private let isLogin = Auth.auth().currentUser != nil
    var wishesExample: [String] = [
        "Хочу сняться в кино  🎬",
        "Хочу сходить в горы  🏔",
        "Хочу сыграть в футбол  ⚽️"
    ]
    
    // MARK: - Binding
    var navigateAuthFlow: (() -> Void)?
    var navigateAppFlow: ((UserViewModel) -> Void)?
    var stopTimer: (() -> Void)?
    
    // MARK: - Private Methods
    public func viewDidLoad() {
        if isLogin {
            print("DEBUG: I am logged in ")
            DB.fetchViewModel(model: User.self, viewModel: UserViewModel.self, ref: Ref.Fire.user(uid: DB.Helper.uid)) { [weak self] (result) in
                switch result {
                case .failure(_):
                    self?.logOut {
                        self?.stopTimer?()
                        self?.navigateAuthFlow?()
                    }
                case .success(let userVM):
                    self?.stopTimer?()
                    self?.navigateAppFlow?(userVM)
                }
            }
        } else {
            stopTimer?()
            navigateAuthFlow?()
        }
    }
    
    private func logOut(completion: @escaping(() -> Void)) {
        if isLogin {
            do {
                DB.Helper.isOnline(bool: false)
                try Auth.auth().signOut()
                Messaging.messaging().unsubscribe(fromTopic: DB.Helper.uid)
                completion()
            } catch {
                completion()
            }
        } else {
            completion()
        }
    }
    
}
