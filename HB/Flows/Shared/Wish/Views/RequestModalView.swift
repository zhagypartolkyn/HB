 

import UIKit

protocol RequestModalViewDelegate: class {
    func handleSendButton(requestText: String)
}

class RequestModalView: UIView {
    
    // MARK: - Variables
    private let delegate: RequestModalViewDelegate
    private var requestSymbolsLimit: Int = 150
    private var keyboardHelper: KeyboardHelper?
    
    // MARK: - Outlets
    private let blurredView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.isUserInteractionEnabled = true
        view.alpha = 0
        return view
    }()
    
    private let cardView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .build()
    
    private let headerView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .build()
    
    private let cancelButton = UIButtonFactory(style: .normal)
        .set(title: LocalizedText.General.cancel)
        .font(Fonts.Paragraph)
        .build()
    
    private let titleLabel = UILabelFactory()
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Paragraph)
        .build()
    
    private let sendButton = UIButtonFactory(style: .normal)
        .set(title: LocalizedText.General.send)
        .build()
    
    private lazy var wishFixedView: WishFixedView = {
        let view = WishFixedView()
        view.delegate = self
        return view
    }()
    
    private let bottomView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .build()
    
    private let textViewBackground = UIViewFactory()
        .corner(radius: 6)
        .build()
    
    private let placeholderLabel = UILabelFactory(text: LocalizedText.wish.requests.INTRODUCE_YOURSELF)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Paragraph)
        .build()
    
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = Fonts.Paragraph
        tv.textColor = UIColor.appColor(.textPrimary)
        tv.backgroundColor = nil
        tv.delegate = self
        return tv
    }()
    
    private lazy var countLabel = UILabelFactory(text: "0 / \(requestSymbolsLimit)")
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Tertiary)
        .build()
    
    private let notRequiredLabel = UILabelFactory(text: "*\(LocalizedText.wish.requests.OPTIONAL_FIELD)")
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Tertiary)
        .build()
    
    // MARK: - View Life Cycle Methods
    init(delegate: RequestModalViewDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setupUI()
        
        blurredView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCancel)))
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        keyboardHelper = KeyboardHelper { [unowned self] animation, keyboardFrame, duration in
            switch animation {
            case .keyboardWillShow:
                cardView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-keyboardFrame.height)
                    make.height.equalTo(260)
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            case .keyboardWillHide: return
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleCancel() {
        cardView.snp.remakeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(260)
            make.height.equalTo(260)
        }
        blurredView.alpha = 0
        endEditing(true)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        } completion: { (status) in
            self.isHidden = true
        }
    }
    
    @objc private func handleSend() {
        delegate.handleSendButton(requestText: textView.text)
        handleCancel()
    }
    
    // MARK: - Public Methods
    public func configureView(title: String, subtitle: String, requestTitle: String) {
        wishFixedView.configureView(title: title, subtitle: subtitle)
        titleLabel.text = requestTitle
    }
    
    public func showModal() {
        cardView.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(260)
        }
        
        blurredView.alpha = 1
        isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        isHidden = true
        
        [blurredView, cardView].forEach { addSubview($0) }
        
        cardView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(260)
            make.height.equalTo(260)
        }
        
        blurredView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        [headerView, wishFixedView, bottomView].forEach { cardView.addSubview($0) }
        
        // Bottom View
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(170)
        }
        
        [notRequiredLabel, textViewBackground].forEach{ bottomView.addSubview($0) }
        
        notRequiredLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(13)
        }
        
        textViewBackground.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(notRequiredLabel.snp.top).offset(-10)
        }
        
        [placeholderLabel, textView, countLabel].forEach{ textViewBackground.addSubview($0) }
        
        placeholderLabel.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(18)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
        
        textView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(countLabel.snp.top).offset(5)
        }
        
        // WishFixedView
        wishFixedView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
            make.height.equalTo(44)
        }
        
        // HeaderView
        headerView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(wishFixedView.snp.top)
            make.height.equalTo(44)
        }
        
        [cancelButton, titleLabel, sendButton].forEach{ headerView.addSubview($0) }
        
        cancelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
    }
    
}

// MARK: - TextView Delegate
extension RequestModalView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" { return false }
        let textCount = (textView.text as NSString).replacingCharacters(in: range, with: text).count
        placeholderLabel.isHidden = textCount != 0
        countLabel.text = textCount <= requestSymbolsLimit ? "\(textCount) / \(requestSymbolsLimit)" : "\(requestSymbolsLimit) / \(requestSymbolsLimit)"
        countLabel.textColor = textCount <= requestSymbolsLimit ? UIColor.appColor(.textSecondary) : UIColor.appColor(.textPrimary)
        return textCount <= requestSymbolsLimit
    }
}

// MARK: - WishFixedView Delegate
extension RequestModalView: WishFixedViewDelegate {
    func handleWish() {}
}
