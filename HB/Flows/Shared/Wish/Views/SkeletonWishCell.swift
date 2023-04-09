 

import UIKit

class SkeletonWishCell: UITableViewCell {

    // MARK: - Variables
    private let avatarImageView = UIImageViewFactory()
        .corner(radius: 25)
        .build()
    
    private let usernameLabel = UILabelFactory()
        .corner(radius: 7)
        .build()
    
    private let dateLabel = UILabelFactory()
        .corner(radius: 7)
        .build()
    
    private let coverImageView = UIImageViewFactory()
        .corner(radius: Constants.Radius.general)
        .build()

    private let titleLabel = UILabelFactory()
        .corner(radius: 7)
        .build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        isSkeletonable = true
        
        [avatarImageView, usernameLabel, dateLabel, coverImageView, titleLabel].forEach {
            $0.isSkeletonable = true
            contentView.addSubview($0)
        }
        
        backgroundColor = UIColor.appColor(.background)
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(50)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.width.equalToSuperview().multipliedBy(0.3)
            make.top.equalTo(avatarImageView).offset(6)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.bottom.equalTo(avatarImageView).offset(-6)
        }
        
        let width = UIScreen.main.bounds.width - 16 - 16
        coverImageView.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
            make.trailing.leading.equalToSuperview().inset(16)
            make.height.equalTo(width * 0.7)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.top.equalTo(coverImageView.snp.bottom).offset(8)
            make.trailing.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
