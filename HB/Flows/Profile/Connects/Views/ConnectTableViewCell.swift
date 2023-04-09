 

import UIKit
import SnapKit

class ConnectTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    let avatarImageView = UIImageViewFactory().content(mode: .scaleAspectFit).corner(radius: 25).build()
    let usernameLabel = UILabelFactory().font(Fonts.Semibold.Paragraph).build()
    let connectsLabel = UILabelFactory().font(Fonts.Semibold.Secondary).text(color: UIColor.appColor(.primary)).build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.appColor(.background)
        selectionStyle = .none
        
        [avatarImageView, usernameLabel, connectsLabel].forEach { contentView.addSubview($0)}
        
        avatarImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.top.leading.bottom.equalToSuperview().inset(16)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        connectsLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

    }

}
