 
 

import UIKit
import Kingfisher
import SnapKit

protocol ProfileHeaderCellDelegate {
    func handleProfileImage()
    func handleProfileEdit()
    func handleFollowers()
    func handleFollowings()
    func handleFollow()
    func handleConnects()
    func handleSegment(_ index: IndexCase)
}

class ProfileHeaderCell: UITableViewCell {
    
    // MARK: - Variables
    var delegate: ProfileHeaderCellDelegate!
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 50)
        .content(mode: .scaleAspectFit)
        .build()
    
    public var connectAvatarImageView1 = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: UIColor.appColor(.textBorder))
        .hide()
        .build()
    
    public var connectAvatarImageView2 = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: UIColor.appColor(.textBorder))
        .hide()
        .build()

    public var connectAvatarImageView3 = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: UIColor.appColor(.textBorder))
        .hide()
        .build()

    public var connectAvatarImageView4 = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: UIColor.appColor(.textBorder))
        .hide()
        .build()

    public var connectAvatarImageView5 = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: UIColor.appColor(.textBorder))
        .hide()
        .build()

    public var connectAvatarImageView6 = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .background(color: UIColor.appColor(.textBorder))
        .hide()
        .build()
    
    private let nameLabel = UILabelFactory()
        .font(Fonts.Heading3)
        .text(color: UIColor.appColor(.textPrimary))
        .text(align: .center)
        .build()
    
    private let locationImageView = UIImageViewFactory(image: Icons.General.pin)
        .tint(color: UIColor.appColor(.textTeritary))
        .build()
    
    private let informationLabel = UILabelFactory()
        .text(align: .center)
        .text(color: UIColor.appColor(.textTeritary))
        .font(Fonts.Semibold.Tertiary)
        .build()
    
    private lazy var informationStackView = UIStackViewFactory(views: [locationImageView, informationLabel])
        .distribution(.fill)
        .spacing(4)
        .build()

    private lazy var userInfoStackView = UIStackViewFactory()
        .axis(.vertical)
        .alignment(.center)
        .spacing(8)
        .distribution(.fill)
        .build()
    
    private let bioLabel = UILabelFactory()
        .text(align: .center)
        .numberOf(lines: 0)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Secondary)
        .build()
    
    // Stat
    private let connectsCounterLabel = UILabelFactory(text: "-")
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textSecondary))
        .text(align: .center)
        .build()
    
    private let connectsLabel = UILabelFactory(text: "Коннектов")
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textTeritary))
        .text(align: .center)
        .build()
    
    private lazy var connectsStackView = UIStackViewFactory(views: [connectsCounterLabel, connectsLabel])
        .axis(.vertical)
        .distribution(.fill)
        .spacing(8)
        .build()
    
    private let connectsDividerView = UIViewFactory().build()
    
    private let followingsCounterLabel = UILabelFactory(text: "-")
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textSecondary))
        .text(align: .center)
        .build()
    
    private let followingsLabel = UILabelFactory(text: LocalizedText.profile.follow.FOLLOWINGS)
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textTeritary))
        .text(align: .center)
        .build()
    
    private lazy var followingsStackView = UIStackViewFactory(views: [followingsCounterLabel, followingsLabel])
        .axis(.vertical)
        .distribution(.fill)
        .spacing(8)
        .build()
    
    private let followingsDividerView = UIViewFactory().build()
    
    private let followersCounterLabel = UILabelFactory(text: "-")
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textSecondary))
        .text(align: .center)
        .build()
    
    private let followersLabel = UILabelFactory(text: LocalizedText.profile.follow.FOLLOWERS)
        .font(Fonts.Tertiary)
        .text(color: UIColor.appColor(.textTeritary))
        .text(align: .center)
        .build()
    
    private lazy var followersStackView = UIStackViewFactory(views: [followersCounterLabel, followersLabel])
        .axis(.vertical)
        .distribution(.fill)
        .spacing(8)
        .build()
    
    private lazy var statStackView = UIStackViewFactory(views: [connectsStackView, followingsStackView, followersStackView])
        .distribution(.fillEqually)
        .alignment(.center)
        .spacing(12)
        .build()
    
    private let editButton = UIButtonFactory()
        .background(color: UIColor.appColor(.background))
        .set(title: LocalizedText.profile.EDIT)
        .title(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Semibold.Tertiary)
        .corner(radius: Constants.Radius.general)
        .border(width: 1)
        .border(color: UIColor.appColor(.textBorder))
        .build()
    
    private let followButton = UIButtonFactory()
        .background(color: UIColor.appColor(.primary))
        .set(title: LocalizedText.profile.FOLLOW)
        .title(color: .white)
        .font(Fonts.Semibold.Tertiary)
        .corner(radius: Constants.Radius.general)
        .hide()
        .build()
    
    private lazy var buttonsStackView = UIStackViewFactory(
        views: [followButton, editButton])
        .spacing(16)
        .build()
    
    private let backgroundCardView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: Constants.Radius.card,
                corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        .build()
    
    private lazy var profileSegmentView = ProfileSegmentView()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        configureActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleEdit() {
        delegate.handleProfileEdit()
    }
    
    @objc private func handleFollow() {
        delegate.handleFollow()
    }
    
    @objc private func handleConnects() {
        delegate.handleConnects()
    }
    
    @objc private func handleFollowers() {
        delegate.handleFollowers()
    }
    
    @objc private func handleFollowings() {
        delegate.handleFollowings()
    }
    
    @objc private func handleAvatar() {
        delegate.handleProfileImage()
    }
    
    // MARK: - Public Methods
    public func configure(user: UserViewModel) {
        avatarImageView.kf.setImage(with: URL(string: user.avatar))
        informationLabel.text = user.information
        
        if !user.name.isEmpty {
            nameLabel.text = user.name
            userInfoStackView.addArrangedSubview(nameLabel)
        }
        
        userInfoStackView.addArrangedSubview(informationStackView)
        
        if !user.bio.isEmpty {
            bioLabel.text = user.bio
            userInfoStackView.addArrangedSubview(bioLabel)
        }
        
        editButton.isHidden = !user.isMe
        followButton.isHidden = user.isMe
        
        followersCounterLabel.text = "\(user.counters.followers)"
        followingsCounterLabel.text = "\(user.counters.followings)"
    }
    
    public func disableFollowButton(disable: Bool) {
        followButton.isEnabled = !disable
    }
    
    public func configureFollowButton(isActive: Bool) {
        followButton.isHidden = false
        followButton.backgroundColor = isActive ? UIColor.appColor(.primary) : UIColor.appColor(.background)
        followButton.setTitle(isActive ? LocalizedText.profile.FOLLOW : LocalizedText.profile.FOLLOWING, for: .normal)
        followButton.setTitleColor(isActive ? .white : UIColor.appColor(.textSecondary), for: .normal)
        followButton.layer.borderWidth = isActive ? 0 : 1
        followButton.layer.borderColor = isActive ? UIColor.clear.cgColor : UIColor.appColor(.textBorder).cgColor
    }
    
    public func configureConnects(topConnects: [ComparableConnect], counter: Int) {
        connectsCounterLabel.text = "\(counter)"
        
        if topConnects.count >= 6 {
            let imageViewsByOrder = [connectAvatarImageView5, connectAvatarImageView2, connectAvatarImageView3, connectAvatarImageView6, connectAvatarImageView4, connectAvatarImageView1]
            imageViewsByOrder.forEach { $0.image = nil }
            for (index, connect) in topConnects.enumerated() {
                if index < 6 {
                    imageViewsByOrder[index].isHidden = false
                    imageViewsByOrder[index].isUserInteractionEnabled = true
                    imageViewsByOrder[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleConnects)))
                    imageViewsByOrder[index].kf.indicatorType = .activity
                    imageViewsByOrder[index].kf.setImage(with: URL(string: connect.imageURL))
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func templateForStatistic(count: Int, text: String, button: UIButton) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\(count)", attributes: [.foregroundColor: UIColor.appColor(.textSecondary), .font: Fonts.Semibold.Paragraph])
        attributedText.append(NSAttributedString(string: "\n\(text)", attributes: [.foregroundColor: UIColor.appColor(.textTeritary), .font: Fonts.Semibold.Tertiary]))
        attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSRange(location: 0, length: attributedText.length))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel?.numberOfLines = 2
    }
    
    private func configureActions() {
        profileSegmentView.delegate = self
        
        [avatarImageView, connectsStackView, followersStackView, followingsStackView].forEach{ $0.isUserInteractionEnabled = true }
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
        connectsStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleConnects)))
        followersStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFollowers)))
        followingsStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFollowings)))
        
        followButton.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        layer.applyCardShadow()
        
        [backgroundCardView, avatarImageView, userInfoStackView, statStackView, buttonsStackView, profileSegmentView].forEach { contentView.addSubview($0) }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        // Connects
        [connectAvatarImageView1, connectAvatarImageView2, connectAvatarImageView3, connectAvatarImageView4, connectAvatarImageView5, connectAvatarImageView6].forEach { contentView.addSubview($0) }
        
        connectAvatarImageView1.snp.makeConstraints { (make) in
            make.right.equalTo(avatarImageView.snp.left).offset(-(UIScreen.main.bounds.width * 0.2))
            make.top.equalTo(avatarImageView).offset(30)
        }
        connectAvatarImageView1.adjustImageWidthAndHeightProportionallyToMainScreen(percent: 0.065, cornerRadiusAfterAdjusting: 0.5)
        
        connectAvatarImageView2.snp.makeConstraints { (make) in
            make.bottom.equalTo(avatarImageView).offset(-14)
            make.right.equalTo(avatarImageView.snp.left).offset(-(UIScreen.main.bounds.width * 0.08))
        }
        connectAvatarImageView2.adjustImageWidthAndHeightProportionallyToMainScreen(percent: 0.1, cornerRadiusAfterAdjusting: 0.5)
        
        connectAvatarImageView3.snp.makeConstraints { (make) in
            make.right.equalTo(avatarImageView.snp.left).offset(-(UIScreen.main.bounds.width * 0.024))
            make.top.equalTo(avatarImageView).offset(16)
        }
        connectAvatarImageView3.adjustImageWidthAndHeightProportionallyToMainScreen(percent: 0.08, cornerRadiusAfterAdjusting: 0.5)
        
        connectAvatarImageView4.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(UIScreen.main.bounds.width * 0.024)
            make.bottom.equalTo(avatarImageView).offset(-16)
        }
        connectAvatarImageView4.adjustImageWidthAndHeightProportionallyToMainScreen(percent: 0.065, cornerRadiusAfterAdjusting: 0.5)
        
        connectAvatarImageView5.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(UIScreen.main.bounds.width * 0.0693)
            make.top.equalTo(avatarImageView).offset(14)
        }
        connectAvatarImageView5.adjustImageWidthAndHeightProportionallyToMainScreen(percent: 0.11, cornerRadiusAfterAdjusting: 0.5)
        
        connectAvatarImageView6.snp.makeConstraints { (make) in
            make.bottom.equalTo(avatarImageView).offset(-30)
            make.left.equalTo(avatarImageView.snp.right).offset(UIScreen.main.bounds.width * 0.1946)
        }
        connectAvatarImageView6.adjustImageWidthAndHeightProportionallyToMainScreen(percent: 0.08, cornerRadiusAfterAdjusting: 0.5)
    
        
        userInfoStackView.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        statStackView.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        buttonsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(statStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        backgroundCardView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonsStackView).offset(16)
        }
        
        profileSegmentView.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundCardView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        contentView.bottomAnchor.constraint(equalTo: profileSegmentView.bottomAnchor).isActive = true
        
        // Additional
        locationImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
        }
        
        statStackView.snp.makeConstraints { (make) in
            make.height.equalTo(72)
        }
        
        [connectsDividerView, followingsDividerView].forEach { contentView.addSubview($0) }

        connectsDividerView.snp.makeConstraints { (make) in
            make.top.equalTo(statStackView)
            make.leading.equalTo(followingsStackView)
            make.height.equalTo(72)
            make.width.equalTo(1)
        }
        
        followingsDividerView.snp.makeConstraints { (make) in
            make.top.equalTo(statStackView)
            make.trailing.equalTo(followingsStackView)
            make.height.equalTo(72)
            make.width.equalTo(1)
        }
        
        followButton.snp.makeConstraints { (make) in
            make.height.equalTo(38)
        }
        
        editButton.snp.makeConstraints { (make) in
            make.height.equalTo(38)
        }
    }
    
}

extension ProfileHeaderCell: ProfileSegmentViewDelegate {
    func handleSegment(_ index: IndexCase) {
        delegate.handleSegment(index)
    }
}
