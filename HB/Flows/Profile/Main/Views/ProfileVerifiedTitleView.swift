 

import UIKit

class ProfileVerifiedTitleView: UIView {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.sizeToFit()
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = Icons.Profile.verifiedSign
        let imageX = label.frame.origin.x + label.frame.size.width + 4
        let imageY = label.frame.origin.y
        let imageWidth = label.frame.size.height
        let imageHeight = label.frame.size.height
        image.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        return image
    }()
    
    private lazy var stackView = UIStackViewFactory(views: [label])
        .distribution(.fill)
        .build()
    
    init(username: String, isVerified: Bool) {
        super.init(frame: .zero)
        [stackView].forEach { addSubview($0) }

        label.text = username
        
        if isVerified {
            stackView.addArrangedSubview(image)
        }
        
        image.isHidden = !isVerified
        stackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
