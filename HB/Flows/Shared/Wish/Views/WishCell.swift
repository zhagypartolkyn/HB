//
 

import UIKit
import SnapKit

protocol WishCellDelegate {
    func avatarAction(viewModel: WishViewModel)
    func moreAction(viewModel: WishViewModel)
    func detailAction(viewModel: WishViewModel)
    func upVoteAction(viewModel: WishViewModel, userWhoLiked: String, touches: Int)
    func downVoteAction(viewModel: WishViewModel, userWhoDisliked: String, touches: Int)
}

class WishCell: UITableViewCell {
    
    // MARK: - Variables
    private var wishVM: WishViewModel?
    var delegate: WishCellDelegate?
    var touchesOnVoteUp: Int = 0
    var touchesOnVoteDown: Int = 0
    
    // MARK: - Outlets
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.background)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.applyCardShadow()
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        return view
    }()
    
    private let avatarImageView = UIImageViewFactory()
        .corner(radius: 10, corners: [.layerMinXMinYCorner, .layerMaxXMaxYCorner])
        .build()
    
    private let usernameLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .text(color: UIColor.appColor(.textPrimary))
        .build()
    
    private let authorInfoLabel = UILabelFactory()
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textSecondary))
        .build()
    
    private let dateLabel = UILabelFactory()
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textTeritary))
        .build()

    private let statusIcon = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .build()
    
    private let statusLabel = UILabelFactory()
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let moreButton = UIButtonFactory()
        .set(image: Icons.General.more)
        .tint(color: UIColor.appColor(.textTeritary))
        .build()
    
    private let coverImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFill)
        .corner(radius: Constants.Radius.general)
        .build()
    
    private let titleLabel = UILabelFactory()
        .font(Fonts.Heading3)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .build()
    
    private let contentStackView = UIStackViewFactory()
        .distribution(.fill)
        .alignment(.fill)
        .axis(.vertical)
        .spacing(16)
        .build()
   
    private let typeLabel = UILabelFactory()
        .text(color: UIColor.appColor(.textSecondary))
        .text(align: .center)
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let typeLabelView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: 5, corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner])
        .border(width: 1)
        .border(color: UIColor.appColor(.textBorder))
        .build()
    
    private let countParticipantsLabel = UILabelFactory()
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let countParticipantsLabelView = UIViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 5, corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner])
        .border(width: 1)
        .border(color: UIColor.appColor(.textBorder))
        .build()
    
    private let historyLabel = UILabelFactory()
        .text(color: UIColor.appColor(.textSecondary))
        .text(align: .center)
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let historyLabelView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: 5, corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner])
        .border(width: 1)
        .border(color: UIColor.appColor(.textBorder))
        .build()
    
    private let countHistoryLabel = UILabelFactory()
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private let countHistoryLabelView = UIViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 5, corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner])
        .border(width: 1)
        .border(color: UIColor.appColor(.textBorder))
        .build()
    
    private let upVoteIconImageView = UIImageViewFactory(image: Icons.Wish.arrowUp)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let downVoteIconImageView = UIImageViewFactory(image: Icons.Wish.arrowDown)
        .tint(color: UIColor.appColor(.textPrimary))
        .content(mode: .scaleAspectFit)
        .build()
        
    private let detailButton = UIButtonFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: Constants.Radius.general)
        .title(color: UIColor.appColor(.primary))
        .font(Fonts.Semibold.Secondary)
        .build()
    
    private let requestsActiveView = UIViewFactory()
        .corner(radius: 5)
        .background(color: UIColor.appColor(.primary))
        .hide()
        .build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        
        [avatarImageView, usernameLabel].forEach {
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
            $0.isUserInteractionEnabled = true
        }
        
        upVoteIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUpVote)))
        upVoteIconImageView.isUserInteractionEnabled = true
        
        downVoteIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDownVote)))
        downVoteIconImageView.isUserInteractionEnabled = true
        
        moreButton.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(handleDetail), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        usernameLabel.text = nil
        dateLabel.text = nil
        titleLabel.text = nil
        authorInfoLabel.text = nil
        requestsActiveView.isHidden = true
        typeLabel.text = nil
        countParticipantsLabel.text = nil
        detailButton.isHidden = false
        typeLabelView.isHidden = false
        countParticipantsLabelView.isHidden = false
        typeLabelView.clipsToBounds = false
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        typeLabelView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().inset(46)
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        typeLabelView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        typeLabelView.clipsToBounds = true
        typeLabelView.layer.cornerRadius = 0
    }
    
    // MARK: - Actions
    @objc func handleAvatar() {
        guard let delegate = delegate, let wishVM = wishVM else { return }
        delegate.avatarAction(viewModel: wishVM)
    }
    
    @objc func handleMore() {
        guard let delegate = delegate, let wishVM = wishVM else { return }
        delegate.moreAction(viewModel: wishVM)
    }
    
    @objc func handleDetail() {
        guard let delegate = delegate, let wishVM = wishVM else { return }
        delegate.detailAction(viewModel: wishVM)
    }
    
    @objc func handleUpVote() {
        touchesOnVoteUp = touchesOnVoteUp + 1
        touchesOnVoteDown = 0
    
        guard let wishVM = wishVM else { return }
        delegate?.upVoteAction(viewModel: wishVM, userWhoLiked: DB.Helper.uid, touches: touchesOnVoteUp)
    }
    
    @objc func handleDownVote() {
        touchesOnVoteDown = touchesOnVoteDown + 1
        touchesOnVoteUp = 0
        
        guard let wishVM = wishVM else { return }
        delegate?.downVoteAction(viewModel: wishVM, userWhoDisliked: DB.Helper.uid, touches: touchesOnVoteDown)
    }
    
    // MARK: - Public Methods
    public func configure(model: WishViewModel) {
        wishVM = model
        avatarImageView.kf.setImage(with: URL(string: model.avatar))
        usernameLabel.text = model.username
        dateLabel.text = model.publishDate
        
        statusIcon.image = model.isComplete ? Icons.Wish.complete : Icons.Wish.active
        statusIcon.tintColor = model.isComplete ? UIColor.appColor(.textSecondary) : UIColor.appColor(.active)
        statusLabel.text = "(\(model.isComplete ? LocalizedText.wish.COMPLETED : LocalizedText.wish.ACTIVE))"
        statusLabel.textColor = model.isComplete ? UIColor.appColor(.textTeritary) : UIColor.appColor(.active)
        
        let location = model.location.city ?? "No City"
        
        let birthday = model.author.birthday
        let birthdayDate = birthday.dateValue()
        let birthdayString = Calendar.current.dateComponents([.year], from: birthdayDate, to: Date()).year!
        
        authorInfoLabel.text = "\(location), \(birthdayString) лет"
        
        titleLabel.text = model.title
        contentStackView.addArrangedSubview(self.titleLabel)
        
        if model.image != "" {
            coverImageView.kf.setImage(with: URL(string: model.image))
            contentStackView.addArrangedSubview(self.coverImageView)
        }
        
        
        if model.isGroupWish {
            countParticipantsLabel.text = "\(model.participants.count + 1)"
            typeLabel.text = LocalizedText.wish.PARTICIPANTS
        } else {
            typeLabel.text = LocalizedText.addWish.SINGLE
            
            countParticipantsLabelView.isHidden = true
            
            typeLabelView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            typeLabelView.clipsToBounds = true
            typeLabelView.layer.cornerRadius = 5
            
            typeLabelView.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().inset(16)
                make.top.equalTo(contentStackView.snp.bottom).offset(16)
                make.height.equalTo(30)
                make.width.equalTo(100)
            }
        }
        
        if model.isComplete {
            detailButton.isHidden = true
        }

        if model.isIParticipate || model.author.uid == DB.Helper.uid{
            detailButton.setTitle(LocalizedText.wish.GO_CHAT, for: .normal)
        } else if model.isGroupWish {
            detailButton.setTitle(LocalizedText.wish.PARTICIPATE, for: .normal)
        } else if !model.isGroupWish {
            detailButton.setTitle(LocalizedText.wish.WANT_TOO, for: .normal)
        }
        
        historyLabel.text = LocalizedText.wish.MOMENTS
        countHistoryLabel.text = model.numberOfHistories
        
        if model.isMyWish {
            self.requestsActiveView.isHidden = !model.isRequestsNotify
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        
        let dateStatusStackView = UIStackViewFactory(views: [dateLabel, statusLabel])
            .distribution(.equalSpacing)
            .spacing(8)
            .build()
        
        let userInfoStackView = UIStackViewFactory(views: [usernameLabel, authorInfoLabel])
            .axis(.vertical)
            .distribution(.fill)
            .spacing(4)
            .build()
        
        let votesStackView = UIStackViewFactory(views: [upVoteIconImageView, downVoteIconImageView])
            .axis(.horizontal)
            .distribution(.fill)
            .spacing(12)
            .build()
        
        
        [avatarImageView, userInfoStackView, dateStatusStackView, moreButton, contentStackView, typeLabelView,countParticipantsLabelView, historyLabelView, countHistoryLabelView, detailButton,votesStackView, requestsActiveView].forEach {
            cardView.addSubview($0)
        }
        
        typeLabelView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        countParticipantsLabelView.addSubview(countParticipantsLabel)
        countParticipantsLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        historyLabelView.addSubview(historyLabel)
        historyLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        countHistoryLabelView.addSubview(countHistoryLabel)
        countHistoryLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        userInfoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
        }
        
        dateStatusStackView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.centerY.equalTo(avatarImageView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        upVoteIconImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(40)
        }
        
        downVoteIconImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(40)
        }
        
        contentStackView.snp.makeConstraints { (make) in
            make.top.equalTo(dateStatusStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        countParticipantsLabelView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.height.width.equalTo(30)
        }
        
        typeLabelView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(46)
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        countHistoryLabelView.snp.makeConstraints { (make) in
            make.leading.equalTo(typeLabelView.snp.trailing).offset(16)
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.height.width.equalTo(30)
        }
        
        historyLabelView.snp.makeConstraints { (make) in
            make.leading.equalTo(typeLabelView.snp.trailing).offset(46)
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        let width = UIScreen.main.bounds.width - 64
        coverImageView.snp.makeConstraints { (make) in
            make.height.equalTo(width * 0.7)
        }

        detailButton.snp.makeConstraints { (make) in
            make.top.equalTo(historyLabelView.snp.bottom).offset(24).priority(999)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.greaterThanOrEqualTo(130)
        }
        
        votesStackView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalTo(detailButton)
        }

        requestsActiveView.snp.makeConstraints { (make) in
            make.top.equalTo(detailButton.snp.top).offset(5)
            make.leading.equalTo(detailButton.snp.trailing).offset(-15)
            make.width.height.equalTo(10)
        }
        
        cardView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(detailButton).offset(16)
        }
        
        let constraint = contentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        constraint.isActive = true
    }
    
}
