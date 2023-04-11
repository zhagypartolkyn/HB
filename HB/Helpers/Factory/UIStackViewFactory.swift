 

import UIKit

final class UIStackViewFactory {
    private let stackView: UIStackView

    // MARK: - Inits
    
    init(views: [UIView]? = nil) {
        if let views = views {
            stackView = UIStackView(arrangedSubviews: views)
        } else {
            stackView = UIStackView()
        }
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
    }

    // MARK: - Public methods
    
    func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        stackView.axis = axis
        return self
    }
    
    func spacing(_ space: CGFloat) -> Self {
        stackView.spacing = space
        return self
    }
    
    func distribution(_ distribution: UIStackView.Distribution) -> Self {
        stackView.distribution = distribution
        return self
    }
    
    func alignment(_ alignment: UIStackView.Alignment) -> Self {
        stackView.alignment = alignment
        return self
    }
    
    func add(selector: Selector) -> Self {
        stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        stackView.isUserInteractionEnabled = true
        return self
    }
    
    func hide() -> Self {
        stackView.isHidden = true
        return self
    }
    
    func height(constant: CGFloat) -> Self {
        stackView.heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }

    func build() -> UIStackView {
        return stackView
    }
}
