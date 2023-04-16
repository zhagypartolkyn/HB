 

import UIKit
import SnapKit

class LogoTitleView: UIView {
    
    // MARK: - Variables
    private let logoImageView = UIImageViewFactory(image: Icons.General.wanty)
        .content(mode: .scaleAspectFit)
        .height(constant: 34)
        .build()
    
    private let logoLabel = UILabelFactory(text: "Hobby-Buddy")
        .font(Fonts.Heading3)
        .build()
    
    private lazy var stackView = UIStackViewFactory(views: [ logoLabel])
        .distribution(.equalCentering)
        .build()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(logoLabel)
        logoLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
}
