//
 

import UIKit

protocol RoomSettingsHeaderCellDelegate {
    func blackListAction()
    func switchAction(status: Bool)
}

class RoomSettingsHeaderCell: UICollectionViewCell {
    
    // MARK: - Variables
    var delegate: RoomSettingsHeaderCellDelegate?
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 50)
        .build()
    
    private let titleLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .text(align: .center)
        .build()
    
    private let subtitleLabel = UILabelFactory()
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textSecondary))
        .build()
    
    private lazy var contentStackView = UIStackViewFactory(views: [avatarImageView, titleLabel, subtitleLabel])
        .axis(.vertical)
        .alignment(.center)
        .distribution(.fill)
        .spacing(8)
        .build()
    
    private let notificationView = UIView()
    
    private let notificationLabel = UILabelFactory(text: LocalizedText.messages.NOTIFICATIONS)
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let notificationSwitch: UISwitch = {
        let nSwitch = UISwitch()
        nSwitch.setOn(true, animated: true)
        nSwitch.onTintColor = UIColor.appColor(.primary)
        return nSwitch
    }()
    
    private let notificationBottomLineView = UIViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .build()
    
    private let blackListView = UIView()
    
    private let blackListLabel = UILabelFactory(text: LocalizedText.messages.BLACKLIST)
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let blackListCounterLabel = UILabelFactory()
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textSecondary))
        .build()
    
    private let blackListArrowImageView = UIImageViewFactory(image: Icons.General.arrow_next).build()
    
    private let blackListBottomLineView = UIViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .build()
    
    private let spaceBottomView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .build()
    
    private let spaceBottomLineView = UIViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    // MARK: - Actions
    @objc private func handleBlackList() {
        delegate?.blackListAction()
    }
    
    @objc private func handleSwitch(_ sender: UISwitch) {
        delegate?.switchAction(status: sender.isOn)
    }
    
    // MARK: - Public Methods
    public func configure(viewModel: RoomViewModel, myNotifyStatus: Bool) {
        avatarImageView.kf.setImage(with: URL(string: viewModel.firstUserThumb))
        titleLabel.text = viewModel.typeIsGroup ? viewModel.wishTitle : viewModel.name
        subtitleLabel.text = viewModel.typeIsGroup ? "\(LocalizedText.messages.PARTICIPANTS)\(viewModel.activeUsers.count)" : LocalizedText.wish.SINGLE_CHAT
        blackListCounterLabel.text = "\(viewModel.deletedUsers.count)"
        notificationSwitch.isOn = myNotifyStatus
    }
    
    // MARK: - Private Methods
    private func setupActions() {
        blackListView.isUserInteractionEnabled = true
        blackListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBlackList)))
        notificationSwitch.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.translatesAutoresizingMaskIntoConstraints = false

        [contentStackView, notificationView, blackListView, spaceBottomView].forEach { contentView.addSubview($0) }
        [notificationLabel, notificationSwitch, notificationBottomLineView].forEach { notificationView.addSubview($0) }
        [blackListLabel, blackListCounterLabel, blackListArrowImageView, blackListBottomLineView].forEach { blackListView.addSubview($0) }
        [spaceBottomLineView].forEach { spaceBottomView.addSubview($0) }
        
        // ContentStackView
        contentStackView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
        }
        
        // Notification
        notificationView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        notificationLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(notificationView)
            make.leading.equalToSuperview().inset(16)
        }
        
        notificationSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(notificationView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        notificationSwitch.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        notificationBottomLineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalTo(notificationView)
            make.leading.trailing.equalToSuperview()
        }
        
        // BlackList
        blackListView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.top.equalTo(notificationView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        blackListLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(blackListView)
            make.leading.equalToSuperview().inset(16)
        }
        
        blackListArrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(blackListView)
            make.trailing.equalToSuperview().inset(22)
        }
        
        blackListCounterLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(blackListView)
            make.trailing.equalTo(blackListArrowImageView).offset(-24)
        }
        
        blackListBottomLineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalTo(blackListView)
            make.leading.trailing.equalToSuperview()
        }
        
        spaceBottomView.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.top.equalTo(blackListBottomLineView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        spaceBottomLineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalTo(spaceBottomView)
            make.leading.trailing.equalToSuperview()
        }
        
        contentView.bottomAnchor.constraint(equalTo: spaceBottomLineView.bottomAnchor, constant: 0).isActive = true
    }
}
