 

import UIKit
import FirebaseFirestore
import Mantis

class EditProfileViewController: UIViewController {
    
    // MARK: - Variables
    private var viewModel = EditProfileViewModel()
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self, withVideo: false)
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .corner(radius: 50)
        .background(color: UIColor.appColor(.textBorder))
        .build()
    
    private let cameraButton = UIButtonFactory(style: .normal)
        .set(image: Icons.General.camera)
        .tint(color: UIColor.appColor(.background))
        .background(color: UIColor.appColor(.primary))
        .corner(radius: 16)
        .build()
    
    private let nameLabel = UILabelFactory(text: LocalizedText.profile.editProfile.NAME, style: .textField).build()
    private let nameTextField = UITextFieldFactory(style: .primary)
        .returnKeyType(.done)
        .disableCorrect()
        .tag(1)
        .build()
    
    private let usernameLabel = UILabelFactory(text: LocalizedText.registration.registerWithEmail.username, style: .textField).build()
    private let usernameTextField = UITextFieldFactory(style: .primary)
        .returnKeyType(.done)
        .forUsername()
        .tag(2)
        .build()
    
    private let bioLabel = UILabelFactory(text: LocalizedText.profile.editProfile.BIO, style: .textField).build()
    private let bioTextField = UITextFieldFactory(style: .primary)
        .returnKeyType(.done)
        .tag(3)
        .build()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegatesAndActions()
        viewModelBinding()
        viewModel.fetchUser()
    }
    
    // MARK: - Actions
    @objc private func handleAvatarImageViewDidTapped(){
        imagePicker.presentAlert()
    }
    
    @objc private func changeUsernameTextField(){
        guard let username = self.usernameTextField.text else { return }
        var usernameChanged = username.replacingOccurrences(of: " ", with: "_")
        usernameChanged = usernameChanged.lowercased()
        self.usernameTextField.text = usernameChanged
    }
    
    @objc private func handleSave() {
        guard let name = nameTextField.text,
              let username = usernameTextField.text,
              let bio = bioTextField.text else { return }
        
        showHUD()
        viewModel.saveUser(name: name, username: username, bio: bio)
    }
    
    // MARK: - Private Methods
    private func viewModelBinding() {
        viewModel.initialSetupUser = { [self] (userVM) in
            avatarImageView.kf.setImage(with: URL(string: userVM.avatar))
            nameTextField.text = userVM.name
            usernameTextField.text = userVM.username
            bioTextField.text = userVM.bio
        }
        
        viewModel.showHudError = { [self] (text) in
            showHUD(type: .error, text: text)
        }
        
        viewModel.showHudSuccess = { [self] (text) in
            showHUD(type: .success, text: text)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Helpers
    private func setupDelegatesAndActions() {
        nameTextField.delegate = self
        usernameTextField.delegate = self
        bioTextField.delegate = self
        
        [avatarImageView, cameraButton].forEach {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatarImageViewDidTapped)))
        }
        
        usernameTextField.addTarget(self, action: #selector(changeUsernameTextField), for: .editingChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedText.General.done, style: .done, target: self, action: #selector(handleSave))
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = UIColor.appColor(.background)
        navigationItem.title = LocalizedText.profile.EDIT_PROFILE
        
        [avatarImageView, cameraButton,
         nameLabel, nameTextField,
         usernameLabel, usernameTextField,
         bioLabel, bioTextField,].forEach { view.addSubview($0) }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        cameraButton.snp.makeConstraints { (make) in
            make.bottom.trailing.equalTo(avatarImageView)
            make.height.width.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(30)
        }
        
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(30)
        }
        
        usernameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        bioLabel.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(30)
        }
        
        bioTextField.snp.makeConstraints { (make) in
            make.top.equalTo(bioLabel.snp.bottom).offset(8)
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}

// MARK: - ImagePicker Delegate
extension EditProfileViewController: ImagePickerDelegate {
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

// MARK: - CropViewController Delegate
extension EditProfileViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        avatarImageView.image = cropped
        viewModel.largeAvatar = cropped
        dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
}

// MARK: - Textfield Delegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
