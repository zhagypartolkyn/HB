 

import UIKit

protocol RequestCellDelegate: class {
    func handleAcceptButton(request: Request)
    func handleDeclineButton(request: Request)
}

class RequestCell: UITableViewCell {
    
    // MARK: - Variables
    private var request: Request?
    weak var delegate: RequestCellDelegate!
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: 25)
        .build()
    
    private let usernameLabel = UILabelFactory()
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Semibold.Paragraph)
        .build()
    
    private let messageLabel = UILabelFactory()
        .numberOf(lines: 0)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Paragraph)
        .build()
    
    private let acceptButton = UIButtonFactory(style: .normal)
        .background(color: UIColor.appColor(.primary)).tint(color: .white)
        .set(image: Icons.General.add)
        .corner(radius: 16)
        .build()
    
    private let declineButton = UIButtonFactory(style: .normal)
        .tint(color: UIColor.appColor(.textSecondary))
        .set(image: Icons.General.cancel)
        .build()
    
    // MARK: - View Life Cycle Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        usernameLabel.text = nil
        messageLabel.text = nil
    }
    
    // MARK: - Action Methods
    @objc func accept() {
        guard let request = request else { return }
        delegate.handleAcceptButton(request: request)
    }
    
    @objc func decline() {
        guard let request = request else { return }
        delegate.handleDeclineButton(request: request)
    }
    
    // MARK: - Public Methods
    public func configure(request: Request) {
        self.request = request
        avatarImageView.kf.setImage(with: URL(string: request.author.thumb))
        usernameLabel.text = request.author.username
        messageLabel.text = request.text
    }
    
    // MARK: - Private Methods
    private func addTargets() {
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(decline), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [ avatarImageView, usernameLabel, messageLabel, acceptButton, declineButton ].forEach { contentView.addSubview($0) }
        
        backgroundColor = UIColor.appColor(.background)
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(50)
        }
        
        declineButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(avatarImageView)
            make.width.height.equalTo(24)
        }
        
        acceptButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(declineButton.snp.leading).offset(-8)
            make.centerY.equalTo(avatarImageView)
            make.width.equalTo(48)
            make.height.equalTo(32)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView).offset(4)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLabel.snp.bottom).offset(4)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalTo(acceptButton.snp.leading).offset(-12)
            make.height.greaterThanOrEqualTo(25)
        }
    }
}

// MARK: - DateHeader Label
class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.appColor(.textBorder)
        textColor = UIColor.appColor(.textPrimary)
        textAlignment = .center
        font = Fonts.Tertiary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 16, height: height)
    }
}
