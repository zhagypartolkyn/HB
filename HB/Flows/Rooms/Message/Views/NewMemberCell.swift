 

import UIKit
import MessageKit
import SnapKit
import Kingfisher

class NewMemberCell: UICollectionViewCell {
    
    // MARK: - Outlets
    private let infoLabel = UILabelFactory(text: LocalizedText.messages.NEWMEMBER)
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.primary))
        .build()
    
    private let usernameLabel = UILabelFactory()
        .font(Fonts.Semibold.Secondary)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let avatarImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFill)
        .corner(radius: 40)
        .build()
    
    private let mainView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: Constants.Radius.card)
        .border(width: 1)
        .border(color: UIColor.appColor(.textSecondary))
        .build()
    
    // MARK: - LifeCycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(mainView)
        [avatarImageView, infoLabel, usernameLabel].forEach { mainView.addSubview($0) }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(80)
            make.center.equalTo(mainView)
        }
        
        mainView.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.height.equalTo(180)
            make.centerX.equalTo(contentView)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(mainView)
            make.top.equalToSuperview().inset(16)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(16)
            make.centerX.equalTo(mainView)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    open func configure(with roomUser: RoomUser?, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let roomUser = roomUser else { return }
        self.avatarImageView.kf.setImage(with: URL(string: roomUser.thumb ?? ""))
        self.usernameLabel.text = roomUser.username
    }
}

// MARK: - Message Size Calculator
open class NewMemberSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        // Customize this function implementation to size your content appropriately. This example simply returns a constant size
        // Refer to the default MessageKit cell implementations, and the Example App to see how to size a custom cell dynamically
        return CGSize(width: 300, height: 120)
    }
}

// MARK: - Message Layout
open class NewMemberMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy open var customMessageSizeCalculator = NewMemberSizeCalculator(layout: self)
    
    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}
