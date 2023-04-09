 

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

protocol HandleAddCoordinate {
    func actionAdd(location: CLLocationCoordinate2D?)
}

class AddMapViewController : UIViewController {
    
    // MARK: - Variables
    private let locationManager = CLLocationManager()
    private var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private let delegate: HandleAddCoordinate
    private let viewModel: AddLocationViewModel
    
    // MARK: - Outlets
    private lazy var mapView: MKMapView = {
        let mv = MKMapView()
        mv.showsUserLocation = true
        mv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMapToRecreateAnnotation)))
        return mv
    }()
    
    private var searchController: UISearchController? = nil
    
    private lazy var locationSearchTable: LocationSearchTable = {
        let table = LocationSearchTable()
        table.mapView = mapView
        table.handleMapSearchDelegate = self
        return table
    }()
    
    private let addButton = UIButtonFactory()
        .set(title: LocalizedText.tabBar.ADD)
        .background(color: UIColor.appColor(.primary))
        .title(color: .white)
        .corner(radius: Constants.Radius.general)
        .addTarget(#selector(handleAdd))
        .build()
    
    // MARK: - LifeCycle
    init(delegate: HandleAddCoordinate, viewModel: AddLocationViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Check for Location Services
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }

        //Zoom to user location
        if let coordinate = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
            recreateAnnotaiton(coordinate: coordinate)
        }
        
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController?.searchResultsUpdater = locationSearchTable
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar
    }
    
    // MARK: - Actions
    @objc func handleMapToRecreateAnnotation(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        recreateAnnotaiton(coordinate: coordinate)
    }
    
    @objc private func handleBack() {
        delegate.actionAdd(location: nil)
        viewModel.navigateBack?()
    }
    
    @objc private func handleAdd() {
        delegate.actionAdd(location: location)
        viewModel.navigateBack?()
    }
    
    // MARK: - Private Methods
    private func recreateAnnotaiton(coordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        location = coordinate
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.General.arrow_back, style: .plain, target: self, action: #selector(handleBack))
        
        [mapView, addButton].forEach { view.addSubview($0) }
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}

extension AddMapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
           let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: placemark.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        location = placemark.coordinate
    }
}
