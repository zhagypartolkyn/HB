 

import UIKit
import Kingfisher

final class UIImageViewFactory {
    
    // MARK: - Outlets
    private let imageView: UIImageView

    // MARK: - LifeCycle
    init(image: UIImage? = nil) {
        imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.kf.indicatorType = .activity
    }

    // MARK: - Methods
    func corner(radius: CGFloat, corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                                          .layerMinXMaxYCorner, .layerMinXMinYCorner]) -> Self {
        imageView.layer.cornerRadius = radius
        imageView.layer.maskedCorners = corners
        imageView.clipsToBounds = true
        return self
    }
    
    func background(color: UIColor) -> Self {
        imageView.backgroundColor = color
        return self
    }
    
    func content(mode: UIView.ContentMode) -> Self {
        imageView.contentMode = mode
        return self
    }

    func tint(color: UIColor) -> Self {
        imageView.tintColor = color
        return self
    }
    
    func height(constant: CGFloat) -> Self {
        imageView.heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    func hide() -> Self {
        imageView.isHidden = true
        return self
    }
    
    func border(color: UIColor) -> Self {
        imageView.layer.borderColor = color.cgColor
        return self
    }
    
    func border(width: CGFloat) -> Self {
        imageView.layer.borderWidth = width
        return self
    }

    func build() -> UIImageView {
        return imageView
    }
}
