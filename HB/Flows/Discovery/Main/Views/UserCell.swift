//
 
import UIKit
import SnapKit

class UserCell: UICollectionViewCell {
    
    // MARK: - Outlets
    private let avatarImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .corner(radius: 40)
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    public func configure(_ thumbUrl: String) {
        avatarImageView.kf.setImage(with: URL(string: thumbUrl))
    }
    
    // MARK: - Setup UI
    func setupUI() {
        addSubview(avatarImageView)
        backgroundColor = .clear
        avatarImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
