 
 

import UIKit
import SnapKit

class WishCompleteCell: UITableViewCell {

    // MARK: - Outlets
    lazy var avatarImageView = UIImageViewFactory().corner(radius: 25).content(mode: .scaleAspectFit).build()
    lazy var usernameLabel = UILabelFactory().font(Fonts.Semibold.Paragraph).build()
    lazy var radioButton = UIImageViewFactory(image: Icons.Profile.radiobutton).content(mode: .scaleAspectFit).build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Actions
    @objc private func handleAvatar() {
        print("avatar click")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        selectionStyle = .none
        
        [avatarImageView, usernameLabel, radioButton].forEach { contentView.addSubview($0) }
        
        avatarImageView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().offset(24)
            make.height.width.equalTo(50)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
        }
        
        radioButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImageView)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
    }

}
