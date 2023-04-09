 

import SwiftUI
import Firebase

class SettingsViewModel: ObservableObject {
    
    // MARK: - Navigate
    var navigateBack: (() -> Void)?
    var navigateRoot: (() -> Void)?
    
    init() {
        if let isPushEnabled = UserDefaults.standard.object(forKey: "push") {
            push = isPushEnabled as! Bool
        } else {
            push = true
        }
    }
    
    // MARK: Variables
    @Published var push: Bool = false {
        didSet {
            UserDefaults.standard.set(push, forKey: "push")
            if push {
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        }
    }
    
    public func logOut() {
        DB.Helper.isOnline(bool: false)
        Messaging.messaging().unsubscribe(fromTopic: DB.Helper.uid)
        
        do {
            try Auth.auth().signOut()
            navigateRoot?()
        } catch {
            debugPrint(error)
        }
    }
}
