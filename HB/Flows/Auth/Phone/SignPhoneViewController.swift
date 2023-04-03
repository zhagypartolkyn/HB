 

import UIKit
import SVProgressHUD

class SignPhoneViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: SignPhoneViewModel
    
    // MARK: - Outlets
    private lazy var mainView = SignPhoneView(delegate: self)
    
    // MARK: - LifeCycle
    init(viewModel: SignPhoneViewModel) {
        self.viewModel = viewModel
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
extension SignPhoneViewController: SignPhoneViewDelegate {
    func close() {
        viewModel.navigateBack?()
    }
    
    func signUp(phoneNumber: String) {
        viewModel.recieveCode(phoneNumber: phoneNumber)
    }
}
