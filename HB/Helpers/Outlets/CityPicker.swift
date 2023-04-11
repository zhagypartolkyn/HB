 

import UIKit
import GooglePlaces

public protocol CityPickerDelegate {
    func updateCity(placeId: String, city: String)
}

open class CityPicker: NSObject {
    
    // MARK: - Variable
    private let delegate: CityPickerDelegate
    private let vc: UIViewController
    
    // MARK: - LifeCycle
    public init(delegate: CityPickerDelegate, vc: UIViewController) {
        self.delegate = delegate
        self.vc = vc
        super.init()
    }
    
    // MARK: - Public Methods
    public func show() {
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        let autocompleteViewController = GMSAutocompleteViewController()
        autocompleteViewController.autocompleteFilter = filter
        autocompleteViewController.delegate = self
        vc.present(autocompleteViewController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func placeIdFrom(_ place: GMSPlace) {
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "en_US"), completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                debugPrint("CityPicker reverseGeocodeLocation \(error)")
                return
            }
            if let placemarks = placemarks, let place = placemarks.first, let adminArea = place.administrativeArea, let countryCode = place.isoCountryCode, let city = place.locality {
                let placeId = "\(countryCode)_\(adminArea)".lowercased().replacingOccurrences(of: " ", with: "_")
                
                UserDefaults.standard.set(placeId, forKey: "placeId")
                UserDefaults.standard.set(city, forKey: "city")
                UserDefaults.standard.set("city", forKey: "type")
                
                self.delegate.updateCity(placeId: placeId, city: city)
            } else {
                debugPrint("Problem with the data received from geocoder")
            }
        })
    }

}

// MARK: - Delegate
extension CityPicker: GMSAutocompleteViewControllerDelegate {
    public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        placeIdFrom(place)
        vc.dismiss(animated: true, completion: nil)
    }
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        debugPrint(error)
    }
    
    public func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}
