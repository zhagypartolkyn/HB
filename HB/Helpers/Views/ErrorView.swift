 

import UIKit
import SnapKit

protocol ErrorViewDelegate: class {
    func handleButton()
}

enum ErrorViewType {
    case chats, requests, notifications,
    myActive, myComplete, myParticipant,
    otherActive, otherComplete,
    singleWishChats, requestsCompleted
    case otherParticipant(String)
}

class ErrorView: UIView {
    
    // MARK: - Outlets
    weak var delegate: ErrorViewDelegate?
    
    // MARK: - Outlets
    private let mainView = UIViewFactory().background(color: .clear).build()
    private let titleLabel = UILabelFactory(text: "Title of errror").numberOf(lines: 0).text(align: .center).font(Fonts.Heading3).build()
    private let subtitleLabel = UILabelFactory(text: "Description of errror").numberOf(lines: 0).text(align: .center).font(Fonts.Paragraph).build()
    private let button = UIButtonFactory(style: .active).set(title: "Call to Action").build()
    private let imageView = UIImageViewFactory(image: Icons.Error.feed).content(mode: .scaleAspectFit).build()
    private lazy var contentStackView = UIStackViewFactory(views: [titleLabel, subtitleLabel, imageView]).spacing(16).distribution(.fill).axis(.vertical).build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.addTarget(self, action: #selector(errorAction), for: .touchUpInside)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc func errorAction() {
        delegate?.handleButton()
    }
    
    // MARK: - Methods
    func configureView(type: ErrorViewType) {
        switch type {
        case .chats:
            titleLabel.text = LocalizedText.messages.title
            subtitleLabel.text = LocalizedText.messages.description
            imageView.image = Icons.Error.feed
        case .singleWishChats:
            titleLabel.text = LocalizedText.wish.singleWishChats.title
            subtitleLabel.text = LocalizedText.wish.singleWishChats.description
            imageView.image = Icons.Error.feed
        case .notifications:
            titleLabel.text = LocalizedText.activities.title
            subtitleLabel.text = LocalizedText.activities.description
            imageView.image = Icons.Error.feed
        case .requests:
            titleLabel.text = LocalizedText.wish.requests.title
            subtitleLabel.text = LocalizedText.wish.requests.description
            imageView.image = Icons.Error.feed
        case .requestsCompleted:
            titleLabel.text = LocalizedText.wish.requests.TITLE_FOR_COMPLETED_WISH
            subtitleLabel.text = LocalizedText.wish.requests.SUBTITLE_FOR_COMPLETED_WISH
            imageView.image = Icons.Error.feed
        case .myActive:
            titleLabel.text = LocalizedText.profile.myActive.title
            subtitleLabel.text = LocalizedText.profile.myActive.description
            button.setTitle(LocalizedText.profile.myActive.button, for: .normal)
            imageView.image = Icons.Error.feed
            contentStackView.insertArrangedSubview(button, at: 2)
        case .myComplete:
            titleLabel.text = LocalizedText.profile.myComplete.title
            subtitleLabel.text = LocalizedText.profile.myComplete.description
            imageView.image = Icons.Error.feed
            
            contentStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        case .myParticipant:
            titleLabel.text = LocalizedText.profile.myParticipant.title
            subtitleLabel.text = LocalizedText.profile.myParticipant.description
            imageView.image = Icons.Error.feed
            
            contentStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        case .otherActive:
            titleLabel.text = LocalizedText.profile.myActive.title
            subtitleLabel.text = LocalizedText.profile.otherActive.description
            imageView.image = Icons.Error.feed
        case .otherComplete:
            titleLabel.text = LocalizedText.profile.myComplete.title
            subtitleLabel.text = LocalizedText.profile.otherComplete.description
            imageView.image = Icons.Error.feed
        case .otherParticipant(let nickname):
            titleLabel.text = String.localizedStringWithFormat(LocalizedText.profile.otherParticipant.title, nickname)
            subtitleLabel.text = String.localizedStringWithFormat(LocalizedText.profile.otherParticipant.description, nickname)
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        mainView.addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
//            make.height.width.equalTo(150)
        }
        
        mainView.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentStackView.snp.bottom)
        }
    }
    
}
