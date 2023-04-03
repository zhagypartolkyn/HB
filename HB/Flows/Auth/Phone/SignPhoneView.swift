 

import UIKit
import SnapKit
import FlagPhoneNumber

protocol SignPhoneViewDelegate: class {
    func close()
    func signUp(phoneNumber: String)
}

class SignPhoneView: UIView {
    
    // MARK: - Variables
    private let delegate: SignPhoneViewDelegate
    
    // MARK: - Outlets
    private lazy var signHeaderView = SignPhoneHeaderView(delegate: self,
                                                     title: LocalizedText.registration.registerWithPhone.enterPhone,
                                                     subtitle: LocalizedText.registration.registerWithPhone.enterCodeDescription)
    
    private let phoneLabel = UILabelFactory(text: LocalizedText.registration.phone, style: .textField).build()
    
    private lazy var phoneTextField: FPNTextField = {
        let textField = FPNTextField()
        textField.setFlag(key: .KZ)
        textField.backgroundColor = UIColor.appColor(.background)
        textField.layer.cornerRadius = 14
        textField.textContentType = .telephoneNumber
        textField.font = Fonts.Secondary
        textField.textColor = UIColor.appColor(.textPrimary)
        textField.backgroundColor = UIColor.appColor(.background)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.appColor(.textTeritary).cgColor
        textField.clipsToBounds = true
        textField.delegate = self
        return textField
    }()
    
    private let signUpButton = UIButtonFactory(style: .active)
        .set(title: LocalizedText.registration.registerWithPhone.recieveCode)
        .background(color: UIColor.appColor(.textTeritary))
        .addTarget(#selector(handleSignUp))
        .isEnabled(false)
        .build()
    
    // MARK: - LifeCycle
    init(delegate: SignPhoneViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleSignUp() {
        guard let phoneNumber = phoneTextField.getFormattedPhoneNumber(format: .E164) else { return }
        delegate.signUp(phoneNumber: phoneNumber)
    }
    
    // MARK: - Setup UI
    func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        
        [signHeaderView, phoneLabel, phoneTextField, signUpButton].forEach { addSubview($0) }
        
        signHeaderView.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    
        phoneLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signHeaderView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        phoneTextField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        signUpButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
    }
}

// MARK: - SignHeaderView Delegate
extension SignPhoneView: SignPhoneHeaderViewDelegate {
    func closeAction() {
        delegate.close()
    }
}

// MARK: - TextField Delegate
extension SignPhoneView: FPNTextFieldDelegate, FormTextFieldBehaviour {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        signUpButton.isEnabled = isValid
        signUpButton.backgroundColor = isValid ? UIColor.appColor(.primary) : UIColor.appColor(.textTeritary)
    }
    
    func fpnDisplayCountryList() {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        defaultTextField(textField: textField)
    }
}
