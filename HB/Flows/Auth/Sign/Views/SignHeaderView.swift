 

import UIKit

protocol SignPhoneHeaderViewDelegate: class {
    func closeAction()
}

class SignPhoneHeaderView: UIView {
    
    // MARK: - Variables
    private let delegate: SignPhoneHeaderViewDelegate?
    
    // MARK: - Outlets
    private let closeButton = UIButtonFactory()
        .set(image: Icons.General.cancel)
        .tint(color: UIColor.appColor(.textSecondary))
        .background(color: UIColor.appColor(.textBorder))
        .corner(radius: Constants.Radius.general)
        .build()
    
    private lazy var stackView = UIStackViewFactory(views: [closeButton])
        .build()
    
    private let titleLabel = UILabelFactory(text: LocalizedText.registration.title)
        .font(Fonts.Heading3)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .build()
    
    private let subtitleLabel = UILabelFactory(text: LocalizedText.registration.description)
        .font(Fonts.Paragraph)
        .text(color: UIColor.appColor(.textSecondary))
        .numberOf(lines: 0)
        .build()
    
    // MARK: - LifeCycle
    init(delegate: SignPhoneHeaderViewDelegate? = nil, title: String, subtitle: String) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setupUI()
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleClose() {
        delegate?.closeAction()
    }
    
    //MARK: - Public Methods
    public func configureSubtitle(_ text: NSMutableAttributedString) {
        subtitleLabel.attributedText = text
    }

    // MARK: - Setup UI
    private func setupUI() {
        [stackView, titleLabel, subtitleLabel].forEach { addSubview($0) }
        
        closeButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.leading.equalTo(snp.leading)
            make.top.equalTo(snp.top)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(24)
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
            make.bottom.equalTo(snp.bottom)
        }
    }
    
}
