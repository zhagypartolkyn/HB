 

import UIKit
import FirebaseAuth
import Mantis
import SnapKit
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self, withVideo: false)
    private lazy var mainView = SignUpView(delegate: self)
    private let viewModel: SignUpViewModel
    
    // MARK: - LifeCycle
    init(viewModel: SignUpViewModel) {
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
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.showHUD = { [self] (type, text) in
            self.showHUD(type: type, text: text)
        }
    }
    
}

// MARK: - MainView Delegate
extension SignUpViewController: SignUpViewDelegate {
    func signUpAction(largeAvatar: UIImage, thumbAvatar: UIImage, username: String, gender: String, birthday: Timestamp) {
        viewModel.signUpAction(largeAvatar: largeAvatar, thumbAvatar: thumbAvatar, username: username, gender: gender, birthday: birthday)
    }
    
    func pickerAction() {
        view.endEditing(true)
        imagePicker.presentAlert()
    }
}

// MARK: - ImagePicker Delegate
extension SignUpViewController: ImagePickerDelegate {
    func didSelect(url: URL) {}
    
    func didSelect(image: UIImage) {
        let cropViewController = Mantis.cropViewController(image: image , config: Mantis.Config())
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1.0 / 1.0)
        DispatchQueue.main.async { [weak self] in
            self?.present(cropViewController, animated: true)
        }
    }
}

// MARK: - ImageCropper Delegate
extension SignUpViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        mainView.configureAvatar(image: cropped)
        dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
}
