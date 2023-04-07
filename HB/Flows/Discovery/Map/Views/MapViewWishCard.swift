 

import UIKit
import SnapKit

protocol MapViewWishCardDelegate: UIViewController {
    func avatarAction(model: WishViewModel)
    func detailAction(model: WishViewModel)
}

class MapViewWishCard: UIView {
 
    // MARK: - Variables
    private let delegate: MapViewWishCardDelegate
    private var wishVM: WishViewModel?
    
    // MARK: - Outlets
    private let parentView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: 20)
        .build()
    
    private let avatarImageView = UIImageViewFactory()
        .corner(radius: 20)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let usernameLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let dateLabel = UILabelFactory()
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textSecondary))
        .numberOf(lines: 1)
        .build()
    
    private let statusIconImageView = UIImageViewFactory(image: Icons.Wish.active)
        .tint(color: UIColor.appColor(.active))
        .build()
    
    private let statusLabel = UILabelFactory(text: LocalizedText.wish.ACTIVE)
        .text(color: UIColor.appColor(.active))
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private lazy var statusStackView = UIStackViewFactory(views: [statusIconImageView, statusLabel])
        .alignment(.fill)
        .distribution(.fill)
        .axis(.horizontal)
        .spacing(4)
        .build()
    
    private let titleLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .build()
    
    private let wishIconImageView = UIImageViewFactory()
        .tint(color: UIColor.appColor(.textSecondary))
        .build()
    
    private let wishTypeLabel = UILabelFactory()
        .font(Fonts.Semibold.Tertiary)
        .text(color: UIColor.appColor(.textSecondary))
        .build()
    
    private let storiesIconImageView = UIImageViewFactory(image: Icons.Wish.history)
        .tint(color: UIColor.appColor(.textSecondary))
        .build()
    
    private let storiesCountLabel = UILabelFactory()
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let detailsButton = UIButtonFactory()
        .background(color: UIColor.appColor(.textBorder))
        .title(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Semibold.Tertiary)
        .corner(radius: 16)
        .content(inset: UIEdgeInsets(top: 16, left: 7, bottom: 16, right: 7))
        .set(title: LocalizedText.General.more)
        .build()
    
    private let moreIconImageView = UIImageViewFactory(image: Icons.General.more)
        .tint(color: UIColor.appColor(.textSecondary))
        .build()
    
    // MARK: - LifeCycle
    init(delegate: MapViewWishCardDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleDetails() {
        guard let wishVM = wishVM else { return }
        delegate.detailAction(model: wishVM)
    }
    
    @objc private func handleAvatar() {
        guard let wishVM = wishVM else { return }
        delegate.avatarAction(model: wishVM)
    }
    
    // MARK: - Public Methods
    public func configure(viewModel: WishViewModel) {
        self.wishVM = viewModel
        avatarImageView.kf.setImage(with: URL(string: viewModel.author.thumb))
        usernameLabel.text = viewModel.username
        dateLabel.text = viewModel.publishDate
        titleLabel.text = viewModel.title
        wishTypeLabel.text = viewModel.isGroupWish ? LocalizedText.addWish.GROUP : LocalizedText.addWish.SINGLE
        storiesCountLabel.text = viewModel.numberOfHistories
        wishIconImageView.image = viewModel.isGroupWish ? Icons.Wish.group : Icons.Wish.single
    }
    
    // MARK: - Private Methods
    private func setupActions() {
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDetails)))
        detailsButton.addTarget(self, action: #selector(handleDetails), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(parentView)
        
        [avatarImageView, usernameLabel, dateLabel, statusStackView, titleLabel, wishIconImageView, wishTypeLabel, storiesIconImageView, storiesCountLabel, detailsButton].forEach {
            parentView.addSubview($0)
        }
        
        parentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(detailsButton).offset(16)
        }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(40)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(19)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(usernameLabel)
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.6)
        }
        
        statusStackView.snp.makeConstraints { (make) in
            make.leading.equalTo(dateLabel.snp.trailing).offset(16)
            make.top.equalTo(dateLabel)
        }
        
        statusIconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        wishIconImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.width.height.equalTo(16)
        }
        
        wishTypeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(wishIconImageView.snp.trailing).offset(4)
            make.top.equalTo(wishIconImageView)
        }
        
        storiesIconImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(wishTypeLabel.snp.trailing).offset(16)
            make.height.width.equalTo(16)
            make.top.equalTo(wishTypeLabel)
        }
        
        storiesCountLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(storiesIconImageView.snp.trailing).offset(4)
            make.top.equalTo(storiesIconImageView)
        }
        
        detailsButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(storiesCountLabel)
            make.height.equalTo(30)
            make.width.equalTo(107)
        }
    }
}
