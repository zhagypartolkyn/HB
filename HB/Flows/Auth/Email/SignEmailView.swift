

import UIKit
import FirebaseFirestore
import SnapKit

protocol SignEmailViewDelegate: class {
    func closeAction()
    func signAction(emailOrUsername: String, password: String)
}

class SignEmailView: UIView {
    
    // MARK: - Variables
    var delegate: SignEmailViewDelegate!
    let isSignIn: Bool
    
    // MARK: - Outlets
    private lazy var pageLabel = UILabelFactory(text: isSignIn ? LocalizedText.General.logIn : LocalizedText.General.signUp)
        .font(Fonts.Heading3)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let closeButton = UIButtonFactory()
        .addTarget(#selector(handleCloseButton))
        .set(image: Icons.General.cancel)
        .tint(color: UIColor.appColor(.textSecondary))
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: Constants.Radius.general)
        .build()

    private lazy var emailLabel = UILabelFactory(text: isSignIn ? LocalizedText.logInPage.email.emailOrUsername : LocalizedText.registration.registerWithEmail.email, style: .textField).build()
    private lazy var emailOrUsernameTextField = UITextFieldFactory(style: .primary)
        .placeholder(isSignIn ? "hobbyinfo@email.com" : LocalizedText.registration.registerWithEmail.email)
        .disableCorrect()
        .forUsername()
        .tag(2)
        .build()
    
    private lazy var passwordLabel = UILabelFactory(text: isSignIn ? LocalizedText.logInPage.email.password : LocalizedText.registration.registerWithEmail.password, style: .textField).build()
    private lazy var passwordTextField = UITextFieldFactory(style: .primary)
        .placeholder(isSignIn ? LocalizedText.logInPage.email.password : LocalizedText.registration.registerWithEmail.passwordPlaceHolder)
        .disableCorrect()
        .forPassword()
        .tag(3)
        .build()
    
    private lazy var signButton = UIButtonFactory(style: .active)
        .set(title: isSignIn ? LocalizedText.General.logIn : LocalizedText.registration.registerWithEmail.next)
        .background(color: UIColor.appColor(.primary))
        .addTarget(#selector(handleSign))
        .build()
    
    // MARK: - LifeCycle
    init(isSignIn: Bool) {
        self.isSignIn = isSignIn
        super.init(frame: .zero)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleCloseButton() {
        self.delegate.closeAction()
    }
    
    @objc private func handleSign() {
        validationForm { [self] (emailOrUsername, password) in
            delegate.signAction(emailOrUsername: emailOrUsername, password: password)
        }
    }
    
    // MARK: - Private Methods
    private func validationForm(completion: @escaping((_ emailOrUsername: String, _ password: String) -> Void)) {
        
        guard let emailOrUsername = emailOrUsernameTextField.text,
              let password = passwordTextField.text else { return }
        
        var isCorrect = true
        
        emailOrUsernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if emailOrUsername.isValidEmail || emailOrUsername.isValidUsername {
            defaultTextField(textField: emailOrUsernameTextField)
        } else {
            errorTextField(textField: emailOrUsernameTextField)
            isCorrect = false
        }
        
        if password.isValidPassword {
            defaultTextField(textField: passwordTextField)
        } else {
            errorTextField(textField: passwordTextField)
            isCorrect = false
        }
        
        if isCorrect {
            completion(emailOrUsername, password)
        }
    }
    
    // MARK: - Helpers
    @objc private func changedEmailTextField() {
        guard let email = self.emailOrUsernameTextField.text else { return }
        let emailChanged = email.replacingOccurrences(of: " ", with: "_")
        emailOrUsernameTextField.text = emailChanged.lowercased()
    }
    
    @objc private func changedPasswordTextField() {
        guard let password = self.passwordTextField.text else { return }
        passwordTextField.text = password.replacingOccurrences(of: " ", with: "")
    }
    
    private func setupActions(){
        emailOrUsernameTextField.delegate = self
        emailOrUsernameTextField.addTarget(self, action: #selector(changedEmailTextField), for: .editingChanged)
        
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(changedPasswordTextField), for: .editingChanged)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        
        [ closeButton, pageLabel,
          emailLabel, emailOrUsernameTextField,
          passwordLabel, passwordTextField,
          signButton ].forEach { addSubview($0) }
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview().offset(32)
            make.height.width.equalTo(44)
        }
        
        pageLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(closeButton)
        }
        
        emailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(pageLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        emailOrUsernameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        passwordLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emailOrUsernameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        passwordTextField.enablePasswordToggle()
    
        signButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
    }
    
}

// MARK: - TextField Delegate
extension SignEmailView: UITextFieldDelegate, FormTextFieldBehaviour {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        defaultTextField(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField.tag {
        case 1: emailOrUsernameTextField.becomeFirstResponder()
        case 2: passwordTextField.becomeFirstResponder()
        default: handleSign()
        }
        return false
    }
}
