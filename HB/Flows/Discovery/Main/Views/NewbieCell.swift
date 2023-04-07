 

import UIKit
import SnapKit
import Kingfisher

class NewbieCell: UICollectionViewCell {
    
    lazy var parentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.background)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appColor(.primary).cgColor
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, nickname, connectsStackView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 40
        imageView.kf.indicatorType = .activity
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nickname: UILabel = {
        let label = UILabel()
        label.font = Fonts.Secondary
        label.textColor = UIColor.appColor(.textPrimary)
        return label
    }()
    
    let connectsLabel = UILabelFactory()
        .text(color: UIColor.appColor(.primary))
        .font(Fonts.Secondary)
        .build()
    
    let connectsImageView = UIImageViewFactory(image: Icons.General.connect)
        .tint(color: UIColor.appColor(.primary))
        .build()
    
    lazy var connectsStackView = UIStackViewFactory(views: [connectsImageView, connectsLabel])
        .spacing(4)
        .distribution(.fill)
        .build()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    func configure(vm: UserViewModel) {
        avatarImageView.kf.setImage(with: URL(string: vm.avatar))
        nickname.text = vm.username
        connectsLabel.text = String(vm.counters.connects ?? 0)
    }
    
    func layoutUI() {
        contentView.addSubview(parentView)
        parentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
        }
        parentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
}
