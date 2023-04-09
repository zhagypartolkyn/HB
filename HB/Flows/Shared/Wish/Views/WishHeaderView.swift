 

import UIKit
import SnapKit

protocol WishHeaderCellDelegate: class {
    func actionAvatar()
    func actionCover()
}

class HeaderWishCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Variables
    private let margin: CGFloat = 16
    weak var delegate: WishHeaderCellDelegate?
    static let identifier = "HeaderCollectionReusableView"
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .corner(radius: Constants.Radius.card)
        .build()
    
    private let usernameLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let dateLabel = UILabelFactory()
        .font(Fonts.Secondary)
        .text(color: UIColor.appColor(.textTeritary))
        .build()
    
    private let statusIcon = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .build()
    
    private let statusLabel = UILabelFactory()
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let contentStackView = UIStackViewFactory()
        .axis(.vertical)
        .distribution(.fill)
        .build()
    
    private let titleLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .build()
    
    private let descriptionLabel = UILabelFactory()
        .font(Fonts.Secondary)
        .text(color: UIColor.appColor(.textSecondary))
        .numberOf(lines: 0)
        .build()
    
    private let coverImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFill)
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: Constants.Radius.general)
        .build()
    
    private let historiesPrimaryLabel = UILabelFactory(text: "Участники")
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.primary))
        .build()
    
    private let historiesSecondaryLabel = UILabelFactory(text: "Участники: 0")
        .font(Fonts.Secondary)
        .text(color: UIColor.appColor(.textTeritary))
        .build()
    
    // MARK: - LifeCycle
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        [avatarImageView, usernameLabel].forEach {
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
            $0.isUserInteractionEnabled = true
        }
        
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCover)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleAvatar() {
        delegate?.actionAvatar()
    }
    
    @objc private func handleCover() {
        delegate?.actionCover()
    }
    
    // MARK: - Public Methods
    public func configure(_ wishVM: WishViewModel, count: Int) {
        historiesSecondaryLabel.text = "Участники: \(count)"
        
        avatarImageView.kf.setImage(with: URL(string: wishVM.avatar))
        usernameLabel.text = wishVM.username
        dateLabel.text = wishVM.publishDate
        statusIcon.image = wishVM.isComplete ? Icons.Wish.complete : Icons.Wish.active
        statusIcon.tintColor = wishVM.isComplete ? UIColor.appColor(.textSecondary) : UIColor.appColor(.active)
        statusLabel.text = wishVM.isComplete ? LocalizedText.wish.COMPLETED : LocalizedText.wish.ACTIVE
        statusLabel.textColor = wishVM.isComplete ? UIColor.appColor(.textTeritary) : UIColor.appColor(.active)
        
        titleLabel.text = wishVM.title
        
        if wishVM.image != "" {
            coverImageView.kf.setImage(with: URL(string: wishVM.image))
            contentStackView.addArrangedSubview(coverImageView)
        }
        contentStackView.addArrangedSubview(titleLabel)
        
        if wishVM.description != "" {
            descriptionLabel.text = wishVM.description
            contentStackView.addArrangedSubview(descriptionLabel)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        
        let statusStackView = UIStackViewFactory(views: [statusIcon, statusLabel])
            .distribution(.equalSpacing)
            .spacing(4)
            .build()
        
        let dateStatusStackView = UIStackViewFactory(views: [dateLabel, statusStackView])
            .distribution(.equalSpacing)
            .spacing(8)
            .build()
        
        let userInfoStackView = UIStackViewFactory(views: [usernameLabel, dateStatusStackView])
            .axis(.vertical)
            .distribution(.fill)
            .spacing(4)
            .build()
        
        [avatarImageView, userInfoStackView, contentStackView, historiesPrimaryLabel, historiesSecondaryLabel].forEach { addSubview($0) }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(margin)
            make.width.height.equalTo(40)
        }
        
        userInfoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
        }
        
        statusIcon.snp.makeConstraints { (make) in
            make.height.width.equalTo(margin)
        }
        
        contentStackView.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(margin)
            make.leading.trailing.equalToSuperview().inset(margin).priority(999) // change
        }
        
        let width = UIScreen.main.bounds.width - margin * 4
        coverImageView.snp.makeConstraints { (make) in
            make.height.equalTo(width * 0.7)
        }
        
        historiesPrimaryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentStackView.snp.bottom).offset(margin*2).priority(999)
            make.leading.trailing.equalToSuperview().inset(margin).priority(999) // change
        }
        
        historiesSecondaryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(historiesPrimaryLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(margin).priority(999) // change
            make.bottom.equalToSuperview().inset(margin)
        }
    }
    
}
