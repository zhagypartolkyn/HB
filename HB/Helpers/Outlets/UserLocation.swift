 
 
import SwiftLocation
import SPPermissions
import FirebaseFirestore
import MapKit

protocol UserLocationFinderDelegate {
    func didAllowLocationPermission()
    func didDeniedPermission()
    
    func update(placeId: String, city: String, type: UserLocationType)
}

enum UserLocationType: String {
    case world = "world"
    case location = "location"
    case city = "city"
}

open class UserLocation: NSObject {
    
    // MARK: - New Methods
    public func getPlaceId(world: Bool) {
        if world {
            updateWithPlaceId("world", city: "Весь мир", type: .world)
        } else {
            get() { (result) in
                switch result {
                case .success(let location):
                    if let placeId = location.placeId, let city = location.city {
                        self.updateWithPlaceId(placeId, city: city, type: .location)
                    } else {
                        print("hzzzzzzzz")
                    }
                case .failure(_):
                    print("self.didDeniedPermission()")
                }
            }
        }
    }
    
    // For initial get
    public func getPlaceId() {
        if let placeId = UserDefaults.standard.string(forKey: "placeId"), placeId != "",
           let city = UserDefaults.standard.string(forKey: "city"), city != "",
           let type = UserDefaults.standard.string(forKey: "type"),
           let typeEnum = UserLocationType(rawValue: type) {
            delegate.update(placeId: placeId, city: city, type: typeEnum)
        } else {
            updateWithPlaceId("world", city: "Весь мир", type: .world)
        }
    }
    
    public func getOnlyPlaceId() -> String {
        if let placeId = UserDefaults.standard.string(forKey: "placeId"), placeId != "",
           let city = UserDefaults.standard.string(forKey: "city"), city != "",
           let type = UserDefaults.standard.string(forKey: "type"),
           let _ = UserLocationType(rawValue: type) {
            return placeId
        } else {
            return "world"
        }
    }
    
    private func updateWithPlaceId(_ placeId: String, city: String, type: UserLocationType) {
        UserDefaults.standard.set(placeId, forKey: "placeId")
        UserDefaults.standard.set(city, forKey: "city")
        UserDefaults.standard.set(type.rawValue, forKey: "type")
        delegate.update(placeId: placeId, city: city, type: type)
    }
    
    
    
    
    
    
    
    

    // MARK: - Variables
    private var delegate: UserLocationFinderDelegate
    private var vc: UIViewController
    private lazy var permission = Permission(delegate: self)

    // MARK: - LifeCycle
    init(delegate: UserLocationFinderDelegate, vc: UIViewController) {
        self.delegate = delegate
        self.vc = vc
        super.init()
    }
    
    // MARK: - Public Methods
    func checkLocationEnabled() -> Bool {
        permission.justCheck(allPermissions: [.locationWhenInUse], viewController: vc)
    }
    
    func get(completion: @escaping(Result<Location, Error>) -> Void) {
        if permission.isEnabled(allPermissions: [.locationWhenInUse], viewController: vc) {
            
            SwiftLocation.gpsLocationWith {
                $0.accuracy = .block
                $0.subscription = .single
            }.then { (result) in
                switch result {
                case .success(let location):
                    let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    print(location)
                    CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "en_US"), completionHandler: {(placemarks, error) -> Void in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        if let placemarks = placemarks, let place = placemarks.first, let adminArea = place.administrativeArea, let countryCode = place.isoCountryCode {
                            
                            let placeLocation = Location(
                                city: place.locality ?? adminArea,
                                country: place.country ?? "",
                                countryCode: countryCode,
                                placeId: "\(countryCode)_\(adminArea)".lowercased().replacingOccurrences(of: " ", with: "_"),
                                geoPoint: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                                placeName: place.locality ?? adminArea
                            )
                            
                            self.updateUser(location: placeLocation)
                            completion(.success(placeLocation))
                            
                        } else {
                            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Placemark error"])))
                        }
                    })
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        } else {
            completion(.failure(NSError(domain: "401", code: 401, userInfo: [NSLocalizedDescriptionKey: "No permission"])))
        }
    }
    
    // MARK: - Private Methods
    private func updateUser(location: Location) {
        let dict: [String : Any] = [
            Ref.User.location.city: location.city as Any,
            Ref.User.location.placeName: location.placeName as Any,
            Ref.User.location.country: location.country as Any,
            Ref.User.location.countryCode: location.countryCode as Any,
            Ref.User.location.placeId: location.placeId as Any,
            Ref.User.location.geoPoint: location.geoPoint as Any
        ]
        
        DB.Helper.updateUser(dict: dict) { (result) in
            switch result {
            case .failure(let error): debugPrint(error)
            case .success: debugPrint("update user")
            }
        }
    }
    
}

// MARK: - Permission Delegate
extension UserLocation: PermissionDelegate {
    public func didAllow(permission: SPPermission) {
        if permission == .locationWhenInUse || permission == .locationAlwaysAndWhenInUse {
            delegate.didAllowLocationPermission()
        }
    }
    
    public func didDenied() {
        delegate.didDeniedPermission()
    }
}
