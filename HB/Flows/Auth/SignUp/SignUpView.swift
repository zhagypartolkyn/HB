 

import UIKit
import SnapKit
import FlagPhoneNumber
import FirebaseFirestore

protocol SignUpViewDelegate: class {
    func pickerAction()
    func signUpAction(largeAvatar: UIImage, thumbAvatar: UIImage, username: String, gender: String, birthday: Timestamp)
}

struct GenderWithTranslate {
    var key: String
    var translated: String
}

class SignUpView: UIView {
    
    // MARK: - Variables
    private let delegate: SignUpViewDelegate
    
    private var avatarImage: UIImage?
    private let genders: [GenderWithTranslate] = [
        GenderWithTranslate(key: LocalizedText.General.other, translated: LocalizedText.General.other),
        GenderWithTranslate(key: Ref.GenderType.male, translated: LocalizedText.General.man),
        GenderWithTranslate(key: Ref.GenderType.female, translated: LocalizedText.General.woman)
    ]
    private var birthday: Timestamp?
    private var gender: String?
    
    // MARK: - Outlets
    private let pageLabel = UILabelFactory(text: LocalizedText.General.signUp)
        .font(Fonts.Heading3)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let avatarDashedView: CustomDashedView = {
        let view = CustomDashedView()
        view.betweenDashesSpace = 10
        view.dashLength = 10
        view.cornerRadius = 75
        view.dashWidth = 3
        view.dashColor = UIColor.appColor(.primary)
        view.backgroundColor = UIColor.appColor(.secondary).withAlphaComponent(0.5)
        return view
    }()
    
    private let avatarIconImageView = UIButtonFactory(style: .normal)
        .set(image: UIImage(named: "cover"))
        .build()
    
    private let avatarTitleLabel = UILabelFactory(text: "Загрузите\nфото")
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .text(align: .center)
        .build()
    
    private lazy var avatarContentStackView = UIStackViewFactory(views: [avatarIconImageView, avatarTitleLabel])
        .distribution(.fill)
        .alignment(.center)
        .axis(.vertical)
        .spacing(0)
        .build()
    
    private let avatarImageView = UIImageViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .tint(color: UIColor.appColor(.textSecondary))
        .hide()
        .build()
    
    private let usernameLabel = UILabelFactory(text: LocalizedText.registration.registerWithEmail.username, style: .textField).build()
    
    private let usernameTextField = UITextFieldFactory(style: .primary)
        .placeholder(LocalizedText.registration.registerWithEmail.username)
        .disableCorrect()
        .forUsername()
        .tag(1)
        .build()
    
    private let genderLabel = UILabelFactory(text: LocalizedText.profile.editProfile.GENDER, style: .textField).build()
    
    private lazy var genderTextField: UITextField = {
        let textField = UITextFieldFactory(style: .primary).build()
        textField.placeholder = LocalizedText.profile.editProfile.GENDER
        textField.inputView = genderPicker
        textField.delegate = self
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(dismissPicker))
        toolBar.tag = 2
        textField.inputAccessoryView = toolBar
        return textField
    }()
    
    private lazy var genderPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private let birthdayLabel = UILabelFactory(text: LocalizedText.registration.registrationFinal.yourBirth, style: .textField).build()
    
    private lazy var birthdayTextField: UITextField = {
        let textField = UITextFieldFactory(style: .primary).build()
        textField.placeholder = "__.__.____"
        textField.inputView = birthdayPicker
        textField.delegate = self
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(dismissPicker))
        textField.inputAccessoryView = toolBar
        return textField
    }()
    
    private let birthdayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = UIColor.appColor(.background)
        picker.tag = 3
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.timeZone = NSTimeZone(name: "GMT")! as TimeZone
        picker.timeZone = TimeZone(secondsFromGMT: 0)
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        picker.maximumDate = Calendar.autoupdatingCurrent.date(byAdding: .year, value: -16, to: Date())
        picker.addTarget(self, action: #selector(handleBirthdayPicker), for: .valueChanged)
        return picker
    }()
    
    private let signUpButton = UIButtonFactory(style: .active)
        .background(color: UIColor.appColor(.primary))
        .set(title: LocalizedText.General.createAccount)
        .build()
    
    private let privacyButton: UIButton = {
        let attributedTitle = NSMutableAttributedString(string: LocalizedText.registration.iAgree,
                                                        attributes: [.font : Fonts.Small, .foregroundColor: UIColor.appColor(.textSecondary)])
        attributedTitle.append(NSAttributedString(string: LocalizedText.registration.terms,
                                                  attributes: [.font : Fonts.Small, .foregroundColor: UIColor.appColor(.primary)]))
        attributedTitle.append(NSAttributedString(string: LocalizedText.registration.andWithSpaces,
                                                  attributes: [.font : Fonts.Small, .foregroundColor: UIColor.appColor(.textSecondary)]))
        attributedTitle.append(NSAttributedString(string: LocalizedText.registration.dataPolicy,
                                                  attributes: [.font : Fonts.Small, .foregroundColor: UIColor.appColor(.primary)]))
        
        let button = UIButtonFactory().build()
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.addTarget(self, action: #selector(handleConfident), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle
    init(delegate: SignUpViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleAvatar() {
        self.delegate.pickerAction()
    }

    @objc private func handleBirthdayPicker(_ sender: UIDatePicker) {
        birthdayTextField.text = sender.date.toFormat("dd.MM.yy")
        birthday = Timestamp(date: sender.date)
    }
    
    @objc func dismissPicker() {
        endEditing(true)
    }
    
    @objc private func handleConfident() {
        if let url = URL(string: "https://www.notion.so/979d17338a94480f8b6a25bc966beeac") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func handleAgreement() {
        if let url = URL(string: "https://www.notion.so/04ed16da2699424e8bc773e81e4f72a9") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func handleSignUp() {
        validationForm { [self] (largeAvatar, thumbAvatar, username, gender, birthday) in
            delegate.signUpAction(largeAvatar: largeAvatar, thumbAvatar: thumbAvatar, username: username, gender: gender, birthday: birthday)
        }
    }
    
    // MARK: - Public Methods
    func configureAvatar(image: UIImage) {
        avatarImage = image
        avatarImageView.image = image
        avatarDashedView.hide()
        avatarContentStackView.isHidden = true
        avatarImageView.isHidden = false
    }
    
    // MARK: - Private Methods
    private func validationForm(completion: @escaping((_ largeAvatar: UIImage,
                                                       _ thumbAvatar: UIImage,
                                                       _ username: String,
                                                       _ gender: String,
                                                       _ birthday: Timestamp) -> Void)) {
        guard let username = usernameTextField.text else { return }
        endEditing(true)
        
        var isCorrect = true
        
        if avatarImage == nil {
            avatarDashedView.color(UIColor.appColor(.dangerous))
            isCorrect = false
        } else {
            avatarDashedView.hide()
        }
        
        if username.isValidUsername {
            defaultTextField(textField: usernameTextField)
        } else {
            errorTextField(textField: usernameTextField)
            isCorrect = false
        }
        
        if let gender = gender, gender != "" {
            defaultTextField(textField: genderTextField)
        } else {
            errorTextField(textField: genderTextField)
            isCorrect = false
        }
        
        if birthday == nil {
            errorTextField(textField: birthdayTextField)
            isCorrect = false
        } else {
            defaultTextField(textField: birthdayTextField)
        }
        
        if isCorrect {
            guard let largeAvatar = avatarImage,
                  let thumbAvatar = largeAvatar.sd_resizedImage(with: CGSize(width: 200, height: 200), scaleMode: .aspectFill),
                  let gender = gender,
                  let birthday = birthday else { return }
            completion(largeAvatar, thumbAvatar, username, gender, birthday)
        }
    }
    
    // MARK: - Helpers
    @objc private func changeUsername() {
        guard let username = self.usernameTextField.text else { return }
        var usernameChanged = username.replacingOccurrences(of: " ", with: "_")
        usernameChanged = usernameChanged.lowercased()
        self.usernameTextField.text = usernameChanged
    }
    
    private func avatarError(_ isError: Bool) {
        avatarImageView.layer.borderWidth = isError ? 1 : 0
        avatarImageView.layer.borderColor = isError ? UIColor.appColor(.dangerous).cgColor : UIColor.appColor(.dangerous).cgColor
    }
    
    private func setupActions(){
        [avatarDashedView, avatarContentStackView, avatarIconImageView, avatarTitleLabel].forEach {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
        }
        
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(changeUsername), for: .editingChanged)
        
        signUpButton.isUserInteractionEnabled = true
        signUpButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSignUp)))
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        
        [pageLabel, avatarDashedView,
         usernameLabel, usernameTextField,
         genderLabel, genderTextField, birthdayLabel, birthdayTextField,
         signUpButton, privacyButton].forEach { addSubview($0) }
        
        pageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
        }
        
        avatarDashedView.snp.makeConstraints { (make) in
            make.top.equalTo(pageLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(150)
        }
        
        [avatarContentStackView, avatarImageView].forEach { avatarDashedView.addSubview($0) }
        
        avatarContentStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(avatarDashedView).inset(24)
        }
        
        avatarIconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(56)
        }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarDashedView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        usernameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        genderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        genderTextField.snp.makeConstraints { (make) in
            make.top.equalTo(genderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        birthdayLabel.snp.makeConstraints { (make) in
            make.top.equalTo(genderTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        birthdayTextField.snp.makeConstraints { (make) in
            make.top.equalTo(birthdayLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        signUpButton.snp.makeConstraints { (make) in
            make.top.equalTo(birthdayTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        privacyButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
    }
    
}

// MARK: - TextField Delegate
extension SignUpView: FormTextFieldBehaviour {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        defaultTextField(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField.tag {
        case 0: usernameTextField.becomeFirstResponder()
        case 1: genderTextField.becomeFirstResponder()
        case 2: birthdayTextField.becomeFirstResponder()
        default:
            handleSignUp()
        }
        
        return false
    }
}

// MARK: - GenderPicker Delegate
extension SignUpView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        genders.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        genders[row].translated
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genders[row].translated
        gender = genders[row].key
    }
}
