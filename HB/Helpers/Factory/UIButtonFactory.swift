 

import UIKit
import SnapKit

final class UIButtonFactory {
    private let button: UIButton

    enum Style {
        case normal
        case sign
        case signNew
        case active
    }

    init(style: Style = .normal) {
        
        button = UIButton()

        switch style {
        case .normal: normalStyle()
        case .sign: signStyle()
        case .signNew: signStyleNew()
        case .active: activeStyle()
        }
    }

    // MARK: - Public methods
    func set(title: String) -> Self {
        button.setTitle(title, for: .normal)
        return self
    }
    
    func set(image: UIImage?) -> Self {
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return self
    }
    
    func setImage(size: CGFloat) -> Self {
        let config = UIImage.SymbolConfiguration(pointSize: size)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        return self
    }
    
    func background(color: UIColor) -> Self {
        button.backgroundColor = color
        return self
    }
    
    func tint(color: UIColor) -> Self {
        button.tintColor = color
        return self
    }
    
    func title(color: UIColor) -> Self {
        button.setTitleColor(color, for: .normal)
        return self
    }
    
    func corner(radius: CGFloat) -> Self {
        button.layer.cornerRadius = radius
        button.clipsToBounds = true
        return self
    }
    
    func font(_ font: UIFont) -> Self {
        button.titleLabel!.font = font
        return self
    }
    
    func swap() -> Self {
        button.semanticContentAttribute = .forceRightToLeft
        return self
    }
    
    func hide() -> Self {
        button.isHidden = true
        return self
    }
    
    func addTarget(_ selector: Selector) -> Self {
        button.addTarget(self, action: selector, for: .touchUpInside)
        return self
    }
    
    func isEnabled(_ isEnabled: Bool) -> Self {
        button.isEnabled = isEnabled
        return self
    }
    
    func border(width: CGFloat) -> Self {
        button.layer.borderWidth = width
        return self
    }
    
    func border(color: UIColor) -> Self {
        button.layer.borderColor = color.cgColor
        return self
    }
    
    func shadow() -> Self {
        button.layer.applyCardShadow()
        return self
    }
    
    func content(inset: UIEdgeInsets) -> Self {
        button.contentEdgeInsets = inset
        return self
    }
    
    func content(mode: UIView.ContentMode) -> Self {
        button.imageView?.contentMode = mode
        return self
    }

    func build() -> UIButton {
        return button
    }

    // MARK: - Private methods
    private func signStyleNew() {
        button.titleLabel?.font = Fonts.Semibold.Paragraph
        button.setTitleColor(UIColor.appColor(.background), for: .normal)
        button.tintColor = UIColor.appColor(.background)
        button.backgroundColor = UIColor.appColor(.primary)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.imageView?.contentMode = .center
        button.imageView?.snp.makeConstraints({ (make) in
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
        })
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24 * 2, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.textAlignment = .left
    }
    
    
    private func signStyle() {
        let iconBoxSize = 34
        let iconRightInset = iconBoxSize / 2 + 24
        
        button.titleLabel?.font = Fonts.Semibold.Paragraph
        button.setTitleColor(UIColor.appColor(.background), for: .normal)
        button.tintColor = UIColor.appColor(.primary)
        button.backgroundColor = UIColor.appColor(.primary)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.imageView?.backgroundColor = UIColor.appColor(.background)
        button.imageView?.layer.cornerRadius = 10
        button.imageView?.contentMode = .center
        button.imageView?.snp.makeConstraints({ (make) in
            make.height.equalTo(iconBoxSize)
            make.width.equalTo(iconBoxSize)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        })
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(iconRightInset), bottom: 0, right: 0)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.textAlignment = .left
    }
    
    private func normalStyle() {
        button.titleLabel?.font = Fonts.Semibold.Paragraph
        button.setTitleColor(UIColor.appColor(.textPrimary), for: .normal)
    }
    
    private func activeStyle() {
        button.titleLabel?.font = Fonts.Semibold.Paragraph
        button.backgroundColor = UIColor.appColor(.primary)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
    }

}
