 

import UIKit

protocol FormTextFieldBehaviour: UITextFieldDelegate {
    func activeTextField(textField: UITextField)
    func defaultTextField(textField: UITextField)
}

extension FormTextFieldBehaviour {
    func activeTextField(textField: UITextField) {
        textField.layer.borderColor = UIColor.appColor(.primary).cgColor
        textField.textColor = UIColor.appColor(.primary)
    }
    
    func defaultTextField(textField: UITextField) {
        textField.layer.borderColor = UIColor.appColor(.textTeritary).cgColor
        textField.textColor = UIColor.appColor(.textPrimary)
    }
    
    func errorTextField(textField: UITextField) {
        textField.layer.borderColor = UIColor.appColor(.dangerous).cgColor
        textField.textColor = UIColor.appColor(.primary)
    }
}

final class UITextFieldFactory {
    private let textField: UITextField
    
    enum Style {
        case normal
        case primary
        case settings
        case smsCode
    }
    
    init(style: Style = .normal, _ paddingLeft: Bool = false) {
        textField = paddingLeft ? TextFieldPaddingLeft() : UITextField()
        
        switch style {
        case .normal: normalStyle()
        case .primary: primaryStyle()
        case .settings: settingsStyle()
        case .smsCode: smsStyle()
        }
    }
    
    // MARK: - Public methods
    func placeholder(_ text: String) -> Self {
        textField.attributedPlaceholder = NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.appColor(.textSecondary)])
        return self
    }
    
    func returnKeyType(_ key: UIReturnKeyType) -> Self {
        textField.returnKeyType = key
        return self
    }
    
    func forEmail() -> Self {
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.textContentType = .emailAddress
        return self
    }
    
    func forUsername() -> Self {
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textContentType = .username
        return self
    }
    
    func forPassword() -> Self {
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.rightViewMode = .unlessEditing
        
        return self
    }
    
    func tag(_ num: Int) -> Self {
        textField.tag = num
        return self
    }
    
    func hide() -> Self {
        textField.isHidden = true
        return self
    }
    
    func disableCorrect() -> Self {
        textField.autocorrectionType = .no
        return self
    }
    
    func forOneTimePassword() -> Self {
        textField.textContentType = .oneTimeCode
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
        return self
    }
    
    func tint(_ color: UIColor) -> Self {
        textField.tintColor = color
        return self
    }
    
    func build() -> UITextField {
        return textField
    }
    
    // MARK: - Helpers
    
    @objc private func togglePasswordView() {
        
    }
    
    // MARK: - Private methods
    
    private func normalStyle() {
        
    }
    
    
    private func primaryStyle() {
        // Create a padding view for padding on left
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: textField.frame.height))
        textField.leftViewMode = .always
        // Create a padding view for padding on right
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: textField.frame.height))
        textField.rightViewMode = .always
        
        textField.font = Fonts.Secondary
        textField.textColor = UIColor.appColor(.textPrimary)
        textField.backgroundColor = UIColor.appColor(.background)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.appColor(.textTeritary).cgColor
        textField.layer.cornerRadius = 14
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ textField.heightAnchor.constraint(equalToConstant: 50) ])
        
        textField.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
    
    private func smsStyle() {
        textField.isUserInteractionEnabled = false
        textField.textAlignment = .center
        textField.font = Fonts.Secondary
        textField.textColor = UIColor.appColor(.textPrimary)
        textField.backgroundColor = UIColor.appColor(.background)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.appColor(.textTeritary).cgColor
        textField.layer.cornerRadius = 14
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ textField.heightAnchor.constraint(equalToConstant: 50) ])
        
        textField.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
    
    private func settingsStyle() {
        textField.backgroundColor = UIColor.appColor(.background)
        textField.textColor = UIColor.appColor(.textPrimary)
        textField.font = Fonts.Paragraph
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ textField.heightAnchor.constraint(equalToConstant: 44) ])
        
        let bottomBorder = UIViewFactory().build()
        textField.addSubview(bottomBorder)
        bottomBorder.bottomAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        bottomBorder.leadingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
        bottomBorder.trailingAnchor.constraint(equalTo: textField.trailingAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true // Set Border-Strength
    }
    
}

extension UITextField {
    func enablePasswordToggle() {
        let button = UIButtonFactory()
            .addTarget(#selector(togglePassword))
            .set(image: self.isSecureTextEntry ? Icons.Sign.passwordShow : Icons.Sign.passwordHide)
            .tint(color: UIColor.appColor(.textSecondary))
            .build()
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 24))
        self.rightView?.addSubview(button)
        self.rightViewMode = .always
    }
    
    @objc private func togglePassword(_ sender: UIButton) {
        self.isSecureTextEntry.toggle()
        sender.setImage(self.isSecureTextEntry ? Icons.Sign.passwordShow : Icons.Sign.passwordHide, for: .normal)
    }
}

// MARK: - Padding for UITextField
class TextFieldPaddingLeft: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
