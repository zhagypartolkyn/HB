 

import UIKit

class PeopleCell: UICollectionViewCell {
    
    // MARK: - Outlets
    private lazy var profileImageView = UIImageViewFactory().corner(radius: 40).build()
    
    private let usernameLabel = UILabelFactory().font(Fonts.Semibold.Secondary).text(color: UIColor.appColor(.textPrimary)).build()

    private let locationImageView = UIImageViewFactory(image: Icons.General.pin).build()
    private let locationLabel = UILabelFactory().font(Fonts.Tertiary).text(color: UIColor.appColor(.textTeritary)).build()
    private lazy var locationStackView = UIStackViewFactory(views: [locationImageView, locationLabel])
        .spacing(4).distribution(.fill).build()
    
    private let connectsImageView = UIImageViewFactory(image: Icons.General.connect).content(mode: .scaleAspectFill).build()
    private let connectsLabel = UILabelFactory().font(Fonts.Semibold.Secondary).text(color: UIColor.appColor(.primary)).build()
    private lazy var connectsStackView = UIStackViewFactory(views: [connectsImageView, connectsLabel])
        .spacing(4).distribution(.fill).build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.applyCardShadow()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    public func setupCell(withModel model: UserViewModel) {
        profileImageView.kf.setImage(with: URL(string: model.avatar))
        usernameLabel.text = model.username
        locationLabel.text = model.cityWithCountryCode
        connectsLabel.text = "\(model.counters.connects ?? 0)"
    }
    
    // MARK: - Setup UI
    private func setupView(){
        backgroundColor = UIColor.appColor(.background)
        layer.cornerRadius = Constants.Radius.card
        [profileImageView, usernameLabel, locationStackView, connectsStackView].forEach{ addSubview($0) }
        
        profileImageView.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(80)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        locationStackView.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        locationImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
        }
        
        connectsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(locationStackView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        connectsImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
            make.height.equalTo(16)
        }
    }
    
}

// MARK: - People Skeleton
class PeopleSkeletonCell: UICollectionViewCell {
    
    // MARK: - Variables
    private let profileImageView = UIImageViewFactory().content(mode: .scaleAspectFill).corner(radius: 40).build()
    private let usernameLabel = UILabelFactory(text: "").numberOf(lines: 1).font(Fonts.Secondary).build()

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func isSkeletonable() {
        isSkeletonable = true
        profileImageView.isSkeletonable = true
        usernameLabel.isSkeletonable = true
        usernameLabel.linesCornerRadius = 10
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [profileImageView, usernameLabel].forEach { contentView.addSubview($0) }
        
        profileImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(80)
            make.top.centerX.equalToSuperview()
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(frame.width)
            make.height.equalTo(frame.height * 0.3)
        }
    }
    
}
