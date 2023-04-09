
import UIKit
import MessageKit
import SnapKit

class InfoMessageCell: UICollectionViewCell {
    
    // MARK: - Outlets
    private let infoLabel = UILabelFactory(text: LocalizedText.addWish.GROUP_CREATED)
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .build()
    
    private let dateLabel = UILabelFactory()
        .font(Fonts.Semibold.Tertiary)
        .text(color: UIColor.appColor(.textSecondary))
        .text(align: .center)
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoLabel.frame = contentView.bounds
    }
    
    // MARK: - Public Methods
    public func configure(with message: Message, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        dateLabel.attributedText = NSAttributedString(string: message.sentDate.toFormat("dd MMM yyyy"),
                                                      attributes: [.font: Fonts.Small, .foregroundColor: UIColor.darkGray])
        
        if message.text == LocalizedText.wish.WISH_COMPLETED { infoLabel.text = LocalizedText.wish.WISH_COMPLETED }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [infoLabel, dateLabel].forEach { contentView.addSubview($0) }
        
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }
    
}

// MARK: - Message Size Calculator
open class InfoMessageCellSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 300, height: 10)
    }
}

// MARK: - Messages Flow Layout
open class InfoMessageCellFlowLayout: MessagesCollectionViewFlowLayout {
    lazy open var customMessageSizeCalculator = InfoMessageCellSizeCalculator(layout: self)
    lazy open var customMessageNewMemberSizeCalculator = NewMemberSizeCalculator(layout: self)
    lazy open var customTextMessageSizeCalculator = CustomTextMessageSizeCalculator(layout: self)
    
    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        customTextMessageSizeCalculator.outgoingAvatarSize = .zero
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! Message
        if message.type == "info" && message.uid.isEmpty {
            return customMessageSizeCalculator
        } else if message.type == "info" && !message.uid.isEmpty {
            return customMessageNewMemberSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}
