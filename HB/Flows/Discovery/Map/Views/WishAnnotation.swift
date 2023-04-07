 

import UIKit
import MapKit

class WishAnnotation: MKPointAnnotation {
    
    // MARK: - Variables
    var id: String
    var type: String
    var viewModel: WishViewModel
    var cover = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    // MARK: - LifeCycle
    init(id: String, type: String, title: String, subtitle: String, coordinate: CLLocationCoordinate2D, viewModel: WishViewModel) {
        self.id = id
        self.type = type
        self.viewModel = viewModel
        
        super.init()
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
