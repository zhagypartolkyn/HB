 

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SignEmailViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: SignViewModel
    let isSignIn: Bool
    
    // MARK: - Outlets
    private lazy var mainView = SignEmailView(isSignIn: isSignIn)
    
    // MARK: - LifeCycle
    init(viewModel: SignViewModel, isSignIn: Bool) {
        self.viewModel = viewModel
        self.isSignIn = isSignIn
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelBinding()
        mainView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Private Methods
    private func viewModelBinding() {
        viewModel.showHUD = { [self] (type, text) in
            self.showHUD(type: type, text: text)
        }
    }
    
}

// MARK: - MainView Delegate
extension SignEmailViewController: SignEmailViewDelegate {
    func closeAction() {
        viewModel.navigateBack?()
    }
    
    func signAction(emailOrUsername: String, password: String) {
        viewModel.signEmailOrUsername(emailOrUsername: emailOrUsername, password: password, isSignIn: isSignIn)
    }
}
