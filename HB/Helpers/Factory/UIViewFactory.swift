 
 

import UIKit

final class UIViewFactory {
    private let view: UIView
    
    // MARK: - Inits
    init() {
        view = UIView()
        view.backgroundColor = UIColor.appColor(.textBorder)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Public methods
    func background(color: UIColor) -> Self {
        view.backgroundColor = color
        return self
    }
    
    func alpha(_ alpha: CGFloat) -> Self {
        view.alpha = alpha
        return self
    }
    
    func corner(radius: CGFloat, corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                                          .layerMinXMaxYCorner, .layerMinXMinYCorner]) -> Self {
        view.layer.cornerRadius = radius
        view.layer.maskedCorners = corners
        view.clipsToBounds = true
        return self
    }
    
    func border(width: CGFloat) -> Self {
        view.layer.borderWidth = width
        return self
    }
    
    func border(color: UIColor) -> Self {
        view.layer.borderColor = color.cgColor
        return self
    }
    
    func addTarget(_ selector: Selector) -> Self {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        return self
    }
    
    func hide() -> Self {
        view.isHidden = true
        return self
    }
    
    func shadow() -> Self {
        view.layer.applyCardShadow()
        return self
    }
    
    func build() -> UIView {
        return view
    }
    
}
