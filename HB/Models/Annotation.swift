 

import UIKit
import MapKit

class Annotation: MKPointAnnotation {
    var id: String?
    var cover = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var type: String?
    var viewModel: WishViewModel?
    
    init(id: String, type: String, title: String, subtitle: String, coordinate: CLLocationCoordinate2D, viewModel: WishViewModel) {
        super.init()
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.viewModel = viewModel
    }
}
