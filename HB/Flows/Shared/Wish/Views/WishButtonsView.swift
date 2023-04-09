 

import UIKit
import SnapKit

protocol WishButtonsStackDelegate: class {
    func handleRequests()
    func handleChat()
    func handleSendRequest()
    func handleWait()
}

class WishButtonsView: UIView {
    
    // MARK: - Variables
    private let delegate: WishButtonsStackDelegate
    
    // MARK: - Outlets
    private let firstButton = UIButtonFactory()
        .corner(radius: Constants.Radius.general)
        .font(Fonts.Semibold.Secondary)
        .build()
    
    private let secondButton = UIButtonFactory()
        .corner(radius: Constants.Radius.general)
        .font(Fonts.Semibold.Secondary)
        .build()
    
    private lazy var buttonsStackView = UIStackViewFactory(views: [firstButton, secondButton])
        .spacing(8)
        .alignment(.fill)
        .distribution(.fillEqually)
        .build()
    
    private let requestNotifyView = UIViewFactory()
        .background(color: UIColor.appColor(.primary))
        .corner(radius: 4)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    init(delegate: WishButtonsStackDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleRequests() {
        delegate.handleRequests()
    }
    
    @objc private func handleChat() {
        delegate.handleChat()
    }
    
    @objc private func handleSendRequest() {
        delegate.handleSendRequest()
    }
    
    @objc private func handleWait() {
        delegate.handleWait()
    }
    
    // MARK: - Public Methods
    public func configure(viewModel: WishViewModel) {
        if viewModel.isMyWish {
            
            setupButton(firstButton, type: .outlined,
                  title: LocalizedText.wish.requests.REQUESTS,
                  selector: #selector(handleRequests))
            
            setupButton(secondButton, type: .primary,
                  title: viewModel.isGroupWish ? LocalizedText.addWish.GROUP : LocalizedText.messages.CHATS,
                  selector: #selector(handleChat))
            
            requestNotifyView.isHidden = !viewModel.isRequestsNotify
            
        } else {
            DB.fetchModels(model: Request.self, query: Queries.Request.check(wishId: viewModel.id), completion: { [self] (result) in
                switch result {
                case .success(_): checkParticipate(viewModel: viewModel, isRequested: true)
                case .failure(_): checkParticipate(viewModel: viewModel, isRequested: false)
                }
            })
        }
    }
    
    // MARK: - Private Methods
    private func checkParticipate(viewModel: WishViewModel, isRequested: Bool) {
        setupButton(firstButton, type: .wishType,
              title: viewModel.isGroupWish ? LocalizedText.addWish.GROUP : LocalizedText.addWish.SINGLE,
              icon: viewModel.isGroupWish ? Icons.Wish.group : Icons.Wish.single)
        
        if viewModel.isIParticipate {
            setupButton(secondButton, type: .outlined, title: LocalizedText.messages.CHAT, selector: #selector(handleChat))
        } else if viewModel.isComplete {
            setupButton(secondButton, type: .isCompleted)
        } else if isRequested {
            setupButton(secondButton, type: .outlined, title: LocalizedText.wish.REQUESTED, selector: #selector(handleWait))
        } else {
            setupButton(secondButton, type: .primary, title: viewModel.isGroupWish ? LocalizedText.wish.PARTICIPATE : LocalizedText.wish.FULFILL, selector: #selector(handleSendRequest))
        }
    }
    
    private func setupButton(_ button: UIButton, type: WishButtonType, title: String? = nil, icon: UIImage? = nil, selector: Selector? = nil) {
        switch type {
        case .wishType:
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.appColor(.textTeritary), for: .normal)
            button.tintColor = UIColor.appColor(.textSecondary)
        case .isCompleted:
            button.backgroundColor = UIColor.appColor(.textTeritary)
            button.setTitleColor(UIColor.appColor(.textPrimary), for: .normal)
            button.setTitle(LocalizedText.wish.COMPLETED, for: .normal)
        case .primary:
            button.backgroundColor = UIColor.appColor(.primary)
            button.setTitleColor(UIColor.appColor(.background), for: .normal)
        case .outlined:
            button.backgroundColor = .clear
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.appColor(.primary).cgColor
            button.setTitleColor(UIColor.appColor(.primary), for: .normal)
        }
        
        button.removeTarget(nil, action: nil, for: .allEvents)
        
        if let icon = icon { button.setImage(icon, for: .normal) }
        if let title = title { button.setTitle(title, for: .normal) }
        if let selector = selector { button.addTarget(self, action: selector, for: .touchUpInside) }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        layer.applyTabBarShadow()
        
        snp.makeConstraints { (make) in
            make.height.equalTo(56)
        }
        
        addSubview(buttonsStackView)
        
        buttonsStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        firstButton.addSubview(requestNotifyView)
        
        requestNotifyView.snp.makeConstraints { (make) in
            make.width.height.equalTo(8)
            make.top.trailing.equalToSuperview().inset(6)
        }
    }
}

enum WishButtonType {
    case wishType
    case primary
    case isCompleted
    case outlined
}
