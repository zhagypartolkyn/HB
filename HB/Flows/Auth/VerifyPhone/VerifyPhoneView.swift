

import UIKit

protocol PhoneViewDelegate: class {
    func submitCode(code: String)
    func back()
}

class VerifyPhoneView: UIView {
    
    // MARK: - Variables
    private let delegate: PhoneViewDelegate
    private var smsCode: String = ""
    
    // MARK: - Outlets
    private lazy var signHeaderView = SignPhoneHeaderView(delegate: self,
                                                     title: LocalizedText.registration.registerWithPhone.enterCode,
                                                     subtitle: LocalizedText.registration.registerWithPhone.enterCodeDescription)
    
    private let codeNumberTextfield = UITextFieldFactory()
        .forOneTimePassword()
        .tint(.clear)
        .build()
    
    private let cellTextField: (() -> UITextField) = {
        return UITextFieldFactory(style: .smsCode).build()
    }
    
    private lazy var cellsStackView = UIStackViewFactory(views: [cellTextField(), cellTextField(), cellTextField(), cellTextField(), cellTextField(), cellTextField()])
        .alignment(.fill)
        .distribution(.fillEqually)
        .spacing(8)
        .build()
    
    private let nextButton = UIButtonFactory(style: .active)
        .set(title: LocalizedText.logInPage.email.next)
        .background(color: UIColor.appColor(.textTeritary))
        .title(color: UIColor.appColor(.background))
        .isEnabled(false)
        .build()
    
    // MARK: - LifeCycle
    init(delegate: PhoneViewDelegate, phoneNumber: String) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        configure(phoneNumber: phoneNumber)
        
        setupUI()
        
        codeNumberTextfield.delegate = self
        codeNumberTextfield.becomeFirstResponder()
        
        let textFieldActive = cellsStackView.subviews[0] as! UITextField
        textFieldActive.layer.borderColor = UIColor.appColor(.primary).cgColor
        
        nextButton.addTarget(self, action: #selector(submitCode), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Actions
    @objc func submitCode() {
        delegate.submitCode(code: smsCode)
    }
    
    // MARK: - Methods
    private func configure(phoneNumber: String) {
        let string = NSMutableAttributedString(string: LocalizedText.registration.registerWithPhone.enterCodeDescription + " ")
        let attributedString = NSAttributedString(string: phoneNumber, attributes: [NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary)])
        string.append(attributedString)
        signHeaderView.configureSubtitle(string)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        [signHeaderView, cellsStackView, codeNumberTextfield, nextButton].forEach {
            addSubview($0)
        }
        
        signHeaderView.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        cellsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(signHeaderView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(cellsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
    }
}

// MARK: - TextField Delegate
extension VerifyPhoneView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text,
              let stringRange = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 6 { return false }
        
        nextButton.isEnabled = updatedText.count == 6
        nextButton.backgroundColor = updatedText.count == 6 ? UIColor.appColor(.primary) : UIColor.appColor(.textTeritary)
        
        if string.count > range.length {
            let textField = cellsStackView.subviews[updatedText.count - 1] as! UITextField
            textField.text = String(updatedText.last!)
            
            if updatedText.count < 6 {
                let textFieldActive = cellsStackView.subviews[updatedText.count] as! UITextField
                let textFieldDeactive = cellsStackView.subviews[updatedText.count - 1] as! UITextField
                textFieldActive.layer.borderColor = UIColor.appColor(.primary).cgColor
                textFieldDeactive.layer.borderColor = UIColor.appColor(.textTeritary).cgColor
            } else {
                let textFieldActive = cellsStackView.subviews[updatedText.count - 1] as! UITextField
                textFieldActive.layer.borderColor = UIColor.appColor(.primary).cgColor
            }
            
        } else {
            let textField = cellsStackView.subviews[updatedText.count] as! UITextField
            textField.text = ""
            
            let textFieldActive = cellsStackView.subviews[updatedText.count] as! UITextField
            textFieldActive.layer.borderColor = UIColor.appColor(.primary).cgColor
            
            if updatedText.count < 5 {
                let textFieldDeactive = cellsStackView.subviews[updatedText.count + 1] as! UITextField
                textFieldDeactive.layer.borderColor = UIColor.appColor(.textTeritary).cgColor
            }
        }
        
        self.smsCode = updatedText
        return true
    }
    
}

// MARK: - SignHeader View Delegate
extension VerifyPhoneView: SignPhoneHeaderViewDelegate {
    func closeAction() {
        delegate.back()
    }
}
