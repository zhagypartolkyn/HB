 

import UIKit

class AddHistoryCell: UICollectionViewCell {
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: DB.Helper.thumb) // BUG: - with helper thumb
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var addLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appColor(.textSecondary)
        label.font = Fonts.Tertiary
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = LocalizedText.tabBar.ADD
        return label
    }()
    
    lazy var addImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.General.add
        imageView.tintColor = UIColor.appColor(.primary)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var background: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.backgroundColor = UIColor.appColor(.textBorder)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        [background, avatarImageView, addImageView, addLabel].forEach { contentView.addSubview($0) }
        
        background.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(36)
            make.leading.top.equalToSuperview().offset(8)
        }
        addImageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        addLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
}
