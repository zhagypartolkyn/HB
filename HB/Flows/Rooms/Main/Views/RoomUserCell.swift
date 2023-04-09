

import UIKit

protocol RoomUserCellDelegate: class {
    func handleReturnOrDelete(roomUserVM: RoomUserViewModel)
}

class RoomUserCell: UICollectionViewCell {
    
    // MARK: - Variables
    var delegate: RoomUserCellDelegate?
    
    private var roomUserViewModel: RoomUserViewModel?
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 25)
        .build()
    
    private let usernameLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let statusLabel = UILabelFactory()
        .font(Fonts.Semibold.Tertiary)
        .text(color: UIColor.appColor(.active))
        .build()
    
    private lazy var stackView = UIStackViewFactory(views: [usernameLabel, statusLabel])
        .axis(.vertical)
        .spacing(4)
        .build()
    
    private let actionButton = UIButtonFactory(style: .normal)
        .font(Fonts.Semibold.Tertiary)
        .title(color: UIColor.appColor(.textSecondary))
        .set(image: Icons.General.cancel)
        .hide()
        .build()
    
    private let notificationViewLine = UIViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .build()

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        usernameLabel.text = ""
        statusLabel.text = ""
        actionButton.isHidden = true
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    // MARK: - Actions
    @objc private func handleAction() {
        guard let roomUserVM = roomUserViewModel else { return }
        delegate?.handleReturnOrDelete(roomUserVM: roomUserVM)
    }
    
    // MARK: - Public Methods
    public func configure(user: RoomUserViewModel) {
        roomUserViewModel = user
        
        avatarImageView.kf.setImage(with: URL(string: user.thumb))
        usernameLabel.text = user.username
        
        statusLabel.text = user.isAdmin ? LocalizedText.messages.wish_author : LocalizedText.messages.MEMBER
        statusLabel.textColor = user.isAdmin ? UIColor.appColor(.primary) : UIColor.appColor(.textPlaceholder)
        statusLabel.setNeedsDisplay()
        
        actionButton.isHidden = user.hideDeleteButton
        actionButton.setImage(user.isDeleted ? Icons.General.add : Icons.General.cancel, for: .normal)
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [avatarImageView, stackView, actionButton, notificationViewLine].forEach { contentView.addSubview($0) }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
        }
    
        actionButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(avatarImageView)
            make.height.width.equalTo(32)
        }
        
        notificationViewLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
        }
        
        contentView.bottomAnchor.constraint(equalTo: notificationViewLine.bottomAnchor, constant: 0).isActive = true
    }
}
