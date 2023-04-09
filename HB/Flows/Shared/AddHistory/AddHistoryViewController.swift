 
import UIKit
import SwiftDate
import SPPermissions
import SDWebImage
import Mantis

protocol AddHistoryDelegate: class {
    func addHistory(vm: HistoryViewModel)
}

class AddHistoryViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: AddHistoryViewModel
    private let delegate: AddHistoryDelegate
    
    private var keyboardHelper: KeyboardHelper?
    
    // MARK: - Outlets
    private let mainBlurredImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFill)
        .corner(radius: Constants.Radius.card, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        .build()
    
    private let blurredEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private let mainImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .build()
    
    private let closeButton = UIButtonFactory()
        .title(color: .white)
        .set(image: Icons.General.cancel)
        .background(color: .clear)
        .addTarget(#selector(back))
        .build()
    
    private let captionLabel = UILabelFactory(text: "\(LocalizedText.addWish.ADD_DESCRIPTION_MINI) (\(LocalizedText.addWish.NOT_NECESSARY))")
        .text(color: UIColor.appColor(.primary))
        .font(Fonts.Paragraph)
        .build()
    
    private let descriptionTextField = UITextFieldFactory(style: .primary)
        .placeholder(LocalizedText.addWish.ADD_DESCRIPTION_MINI)
        .disableCorrect()
        .forUsername()
        .build()
    
    private let sendButton = UIButtonFactory()
        .background(color: UIColor.appColor(.primary))
        .title(color: .white)
        .corner(radius: Constants.Radius.general)
        .addTarget(#selector(sendHistory))
        .set(title: LocalizedText.wish.addHistory.NEW_HISTORY)
        .build()
    
    private lazy var contentStackView = UIStackViewFactory(views: [captionLabel, descriptionTextField, sendButton])
        .axis(.vertical)
        .spacing(8)
        .distribution(.fill)
        .build()
    
    private let contentBackgroundView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: Constants.Radius.card)
        .build()
    
    // MARK: - LifeCycle
    init(viewModel: AddHistoryViewModel, delegate: AddHistoryDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        mainImageView.image = viewModel.largeImage
        mainBlurredImageView.image = viewModel.largeImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureKeyboard()
        viewModelBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Actions
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func sendHistory() {
        viewModel.createHistory(description: descriptionTextField.text)
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.showHUD = { [weak self] (type, text) in
            self?.showHUD(type: type, text: text)
        }
        
        viewModel.sendCreatedHistory = { [weak self] (historyVM) in
            self?.delegate.addHistory(vm: historyVM)
        }
    }
    
    // MARK: - Private Methods
    private func configureKeyboard() {
        keyboardHelper = KeyboardHelper { [unowned self] animation, keyboardFrame, duration in
            switch animation {
            case .keyboardWillShow:
                contentStackView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(32)
                    make.bottom.equalToSuperview().offset(-keyboardFrame.height - 24)
                }
                view.layoutIfNeeded()
            case .keyboardWillHide:
                contentStackView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(32)
                    make.bottom.equalTo(view.safeAreaLayoutGuide).offset( -16 )
                }
                view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [mainBlurredImageView, closeButton, contentBackgroundView, contentStackView].forEach { view.addSubview($0) }
        
        mainBlurredImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        [blurredEffectView, mainImageView].forEach{ mainBlurredImageView.addSubview($0) }
        
        blurredEffectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        mainImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        
        contentStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        contentBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(contentStackView).offset(-16)
            make.trailing.equalTo(contentStackView).offset(16)
            make.bottom.equalTo(contentStackView).offset(16)
            make.leading.equalTo(contentStackView).offset(-16)
        }
        
        captionLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
        }
        descriptionTextField.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
        }
        sendButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(44)
        }
        
    }
}

// MARK: - UITextView Delegate
extension AddHistoryViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == LocalizedText.addWish.ADD_DESCRIPTION_MINI {
            textView.text = ""
            textView.textColor = UIColor.appColor(.textSecondary)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "\(LocalizedText.addWish.ADD_DESCRIPTION_MINI) (\(LocalizedText.addWish.NOT_NECESSARY))"
        }
    }
}
