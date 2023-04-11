 

import UIKit

final class UILabelFactory {
    private let label: UILabel

    // MARK: - Inits
    enum Style {
        case normal
        case textField
    }

    init(text: String? = nil, style: Style = .normal) {
        
        label = UILabel()
        label.text = text
        label.font = Fonts.Paragraph
        label.translatesAutoresizingMaskIntoConstraints = false

        switch style {
        case .normal: normalStyle()
        case .textField: textFieldStyle()
        }
        
    }

    // MARK: - Public methods
    func font(_ font: UIFont) -> Self {
        label.font = font
        return self
    }

    func text(color: UIColor) -> Self {
        label.textColor = color
        return self
    }
    
    func text(align: NSTextAlignment) -> Self {
        label.textAlignment = align
        return self
    }

    func numberOf(lines: Int) -> Self {
        label.numberOfLines = lines
        return self
    }
    
    func background(color: UIColor) -> Self {
        label.backgroundColor = color
        return self
    }
    
    func corner(radius: CGFloat) -> Self {
        label.layer.cornerRadius = radius
        label.clipsToBounds = true
        return self
    }
    
    func hide() -> Self {
        label.isHidden = true
        return self
    }
    
    func build() -> UILabel {
        return label
    }
    
    // MARK: - Private methods
    
    private func normalStyle() {
    }
    
    private func textFieldStyle() {
        label.textColor = UIColor.appColor(.textSecondary)
        label.font = Fonts.Semibold.Tertiary
    }
    
}
