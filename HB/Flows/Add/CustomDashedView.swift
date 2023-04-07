 

import UIKit

class CustomDashedView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0

    var dashBorder: CAShapeLayer?
    
    func hide(_ status: Bool = true) {
        dashWidth = status ? 0 : 3
        layoutSubviews()
    }
    
    func color(_ color: UIColor) {
        dashColor = color
        layoutSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        dashBorder.path = cornerRadius > 0 ? UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath : UIBezierPath(rect: bounds).cgPath

        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
} 
