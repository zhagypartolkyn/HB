 

import UIKit
import MapKit

class WishMKAnnotationView: MKAnnotationView {
    
    // MARK: - Variables
    let cellIdentifier: String = "WishMKAnnotationView"
    
    // MARK: - Outlets
    private let userImageView = UIImageViewFactory()
        .content(mode: .scaleAspectFit)
        .corner(radius: 25)
        .border(color: UIColor.appColor(.primary))
        .build()
    
    // MARK: - LifeCycle
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
        
//        clusteringIdentifier = "locatedPhoto"
//        collisionMode = .circle
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            if let annotation = newValue as? WishAnnotation {
                userImageView.image = annotation.cover.image
//                clusteringIdentifier = "locatedPhoto"
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    public func activeBorder(_ status: Bool) {
        userImageView.layer.borderWidth = status ? 3 : 0
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        isUserInteractionEnabled = true
        addSubview(userImageView)
        
        snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
        }
        
        userImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
        }
    }
    
}
