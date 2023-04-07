 

import UIKit

class RoomCell: UITableViewCell {
    
    // MARK: - Variables
    lazy private var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 30)
        .build()
    
    private let secondAvatarImageView = UIImageViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .border(width: 2)
        .border(color: UIColor.appColor(.background))
        .corner(radius: 15)
        .build()
    
    private let wishLabel = UILabelFactory()
        .font(Fonts.Semibold.Secondary)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let roomNameLabel = UILabelFactory()
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.primary))
        .build()
    
    private let messageLabel = UILabelFactory()
        .font(Fonts.Semibold.Secondary)
        .text(color: UIColor.appColor(.textSecondary))
        .build()
    
    private lazy var labelsStackView = UIStackViewFactory(views: [wishLabel, roomNameLabel, messageLabel]).spacing(4).axis(.vertical).build()
    
    private let dateLabel = UILabelFactory().font(Fonts.Tertiary).text(color: UIColor.appColor(.textSecondary)).build()
    private let newMessagesView = UIViewFactory().background(color: UIColor.appColor(.primary)).corner(radius: 4).hide().build()
    
    private let bottomLineView = UIViewFactory().background(color: UIColor.appColor(.textBorder)).build()

    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    // MARK: - Public Methods
    public func configure(viewModel: RoomViewModel) {
        wishLabel.text = viewModel.wishTitle
        roomNameLabel.text = viewModel.name
        messageLabel.text = viewModel.messageText
        dateLabel.text = viewModel.messageTime
        
        if viewModel.typeIsGroup {
            secondAvatarImageView.isHidden = false
            avatarImageView.kf.setImage(with: URL(string: viewModel.firstUserThumb))
            secondAvatarImageView.kf.setImage(with: URL(string: viewModel.secondUserThumb))
        } else {
            secondAvatarImageView.isHidden = true
            avatarImageView.kf.setImage(with: URL(string: viewModel.firstUserThumb))
        }
        
        if let user = viewModel.allUsers[DB.Helper.uid] {
            newMessagesView.isHidden = user.read
        }
    }
 
    // MARK: - Setup UI
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor.appColor(.background)
        contentView.autoresizingMask = .flexibleHeight
        
        [avatarImageView, secondAvatarImageView,
         labelsStackView, dateLabel, newMessagesView, bottomLineView].forEach { contentView.addSubview($0) }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(60)
        }
        
        secondAvatarImageView.snp.makeConstraints { (make) in
            make.bottom.trailing.equalTo(avatarImageView)
            make.height.width.equalTo(30)
        }
        
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(60)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(wishLabel)
            make.trailing.equalToSuperview().inset(16)
        }
        
        newMessagesView.snp.makeConstraints { (make) in
            make.centerY.equalTo(messageLabel)
            make.leading.equalTo(dateLabel)
            make.height.width.equalTo(8)
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.equalTo(avatarImageView)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        contentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomLineView.bottomAnchor, constant: 0).isActive = true
    }
}
