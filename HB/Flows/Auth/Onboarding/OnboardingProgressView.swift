 

import UIKit

class OnboardingProgressView: UIView {
    
    // MARK: - Variables
    private lazy var progressLayer: CAShapeLayer = {
        var circularPath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
            radius: 35,
            startAngle: -.pi / 2, endAngle: 3 * .pi / 2,
            clockwise: true)
        
        let layer = CAShapeLayer()
        layer.path = circularPath.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineWidth = 3.0
        layer.strokeEnd = 0
        layer.strokeColor = UIColor.appColor(.primary).cgColor
        return layer
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func layoutSubviews() {
        layer.addSublayer(progressLayer)
    }
    
    // MARK: - Public Methods
    public func progressAnimation(from: CGFloat, to: CGFloat) {
        DispatchQueue.main.async {
            let baseAnimation = CABasicAnimation(keyPath: "strokeEnd")
            baseAnimation.duration = 0
            baseAnimation.toValue = from
            baseAnimation.fillMode = .forwards
            baseAnimation.isRemovedOnCompletion = false
            
            self.progressLayer.add(baseAnimation, forKey: "baseAnim")
            
            let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
            circularProgressAnimation.duration = 0.2
            circularProgressAnimation.fromValue = from
            circularProgressAnimation.toValue = to
            circularProgressAnimation.fillMode = .forwards
            circularProgressAnimation.isRemovedOnCompletion = false
            self.progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        }
    }
    
}
