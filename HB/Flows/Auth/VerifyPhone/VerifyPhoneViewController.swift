 

import UIKit
import FirebaseAuth

class VerifyPhoneViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: SignViewModel
    private var phoneNumber: String
    
    // MARK: - LifeCycle
    init(viewModel: SignViewModel, phoneNumber: String) {
        self.viewModel = viewModel
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelBinding()
    }
    
    override func loadView() {
        view = VerifyPhoneView(delegate: self, phoneNumber: phoneNumber)
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.showHUD = { [self] (type, text) in
            self.showHUD(type: type, text: text)
        }
    }
}

// MARK: - MainView Delegate
extension VerifyPhoneViewController: PhoneViewDelegate {
    func submitCode(code: String) {
        showHUD()
        let verificationID = UserDefaults.standard.string(forKey: Ref.Wish.id)
        let credential = PhoneAuthProvider.provider().credential( withVerificationID: verificationID!, verificationCode: code)
        viewModel.sign(credentials: credential, type: .phone)
    }
    
    func back() {
        viewModel.navigateBack?()
    }
}
