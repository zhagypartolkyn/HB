 

import UIKit

final class PeopleSearchCell: UITableViewCell {
    
    // MARK: - Outlets
    private var profileImageView  = UIImageViewFactory()
        .corner(radius: 32)
        .build()
    
    private var usernameLabel = UILabelFactory()
        .font(Fonts.Semibold.Paragraph)
        .build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    public func configure(avatarUrl: String, username: String){
        profileImageView.kf.setImage(with: URL(string: avatarUrl))
        usernameLabel.text = username
    }
    
    // MARK: - Setup UI
    private func setupUI(){
        backgroundColor = .clear
        selectionStyle = .none
        
        [profileImageView, usernameLabel].forEach{ addSubview($0) }
        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(64)
            make.top.bottom.leading.equalToSuperview().inset(16)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
    }
}
