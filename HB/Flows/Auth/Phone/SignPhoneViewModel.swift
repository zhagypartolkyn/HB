//
 

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SignPhoneViewModel {
    
    // MARK: - Binding
    var showHUD: ((_ type: AlertType, _ text: String) -> Void)?
    var navigateVerifyPhone: ((_ number: String) -> Void)?
    var navigateRoot: (() -> Void)?
    var navigateBack: (() -> Void)?
    
    // MARK: - Methods
    func recieveCode(phoneNumber: String) {
        showHUD?(.loading, "")
        
        Auth.auth().languageCode = "en"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.showHUD?(.error, error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: Ref.Wish.id)
            self.showHUD?(.dismiss, "")
            self.navigateVerifyPhone?(phoneNumber)
        }
    }
    
}
