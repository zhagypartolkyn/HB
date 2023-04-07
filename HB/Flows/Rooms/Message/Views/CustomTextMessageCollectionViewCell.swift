 

import UIKit
import MessageKit
import SnapKit
import Kingfisher

class CustomTextMessageCollectionViewCell: TextMessageCell {
    
    lazy var viewMessageForm: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor(red: 0.035, green: 0.384, blue: 1, alpha: 0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.333, green: 0.42, blue: 0.565, alpha: 1)
        label.font = Fonts.Tertiary
        return label
    }()
    
    lazy var timeLabel: InsetLabel = {
        let label = InsetLabel()
        label.textColor = UIColor(red: 0.659, green: 0.706, blue: 0.78, alpha: 1)
        label.font = Fonts.Small
        return label
    }()
    
    
    lazy var viewSquareRight: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        
        view.backgroundColor = UIColor(red:0.00, green:0.36, blue:1.00, alpha:1.00)
        
        view.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
        }
        return view
    }()
    
    lazy var viewSquareLeft: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        
        view.backgroundColor = .white
        
        view.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
        }
        return view
    }()
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            return
        }
        viewMessageForm.layer.cornerRadius = 14
        messageTopLabel.isHidden = true
        messageBottomLabel.isHidden = true
        messageContainerView.backgroundColor = .clear
        nameLabel.attributedText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
        timeLabel.text = messageBottomLabel.text
        timeLabel.snp.updateConstraints { (make) in
            make.trailing.equalTo(viewMessageForm).offset(-16)
            make.bottom.equalTo(viewMessageForm).offset(-8)
        }
        
        if dataSource.isFromCurrentSender(message: message) {
            viewMessageForm.frame = CGRect(x: messageContainerView.frame.minX, y: messageContainerView.frame.minY, width: messageContainerView.frame.width, height: messageContainerView.frame.height + 24)
            viewMessageForm.backgroundColor = UIColor(red:0.00, green:0.36, blue:1.00, alpha:1.00)
            viewSquareRight.backgroundColor = UIColor(red:0.00, green:0.36, blue:1.00, alpha:1.00)
            viewSquareRight.isHidden = false
            viewSquareLeft.isHidden = true
        } else {
            nameLabel.isHidden = false
            viewMessageForm.frame = CGRect(x: messageContainerView.frame.minX, y: messageContainerView.frame.minY-32, width: messageContainerView.frame.width, height: messageContainerView.frame.height + 32 + 24)
            
            nameLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(viewMessageForm).offset(16)
                make.top.equalTo(viewMessageForm).offset(16)
            }
            viewMessageForm.backgroundColor = .white
            viewSquareRight.isHidden = true
            viewSquareLeft.isHidden = false
            avatarView.isHidden = false
        }
    }

    
    override func setupSubviews() {
        super.setupSubviews()
        contentView.addSubview(viewMessageForm)
        contentView.addSubview(viewSquareRight)
        contentView.addSubview(viewSquareLeft)
        contentView.addSubview(messageContainerView)
        viewMessageForm.addSubview(nameLabel)
        viewMessageForm.addSubview(timeLabel)
        
        
        viewSquareRight.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
            make.right.bottom.equalTo(viewMessageForm)
        }
        viewSquareLeft.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
            make.left.bottom.equalTo(viewMessageForm)
        }
    }
    
}

// MARK: - Message Size Calculator
open class CustomTextMessageSizeCalculator: TextMessageSizeCalculator {
    open override func avatarSize(for message: MessageType) -> CGSize {
        
        outgoingAvatarSize = .zero
        incomingAvatarSize = CGSize(width: 38, height: 38)
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAvatarSize : incomingAvatarSize
    }
    
}
