 

import UIKit
import SnapKit
import Kingfisher

class StarCell: UICollectionViewCell {
    
    lazy var parentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.background)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appColor(.secondary).cgColor
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, nickname])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.kf.indicatorType = .activity
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nickname: UILabel = {
        let label = UILabel()
        label.font = Fonts.Secondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.appColor(.textPrimary)
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    func configure(vm: UserViewModel) {
        avatarImageView.kf.setImage(with: URL(string: vm.avatar))
        
        let fullString = NSMutableAttributedString(string: "\(vm.username)  ")
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = Icons.Profile.verifiedSign
        let image1String = NSAttributedString(attachment: image1Attachment)

        fullString.append(image1String)

        nickname.attributedText = setUsername(username: vm.username)
        
    }
    
    func setUsername(username: String) -> NSAttributedString {
        let fullString = NSMutableAttributedString(string: "\(username)  ")
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = Icons.Profile.verifiedSign
        let image1String = NSAttributedString(attachment: image1Attachment)

        fullString.append(image1String)
        
        return fullString
    }
    
    func layoutUI() {
        contentView.addSubview(parentView)
        
        parentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        parentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(150)
        }
        
        parentView.addSubview(nickname)
        nickname.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
}
