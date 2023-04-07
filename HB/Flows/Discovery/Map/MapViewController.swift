 

import UIKit
import MapKit
import FirebaseFirestore
import SnapKit

class MapViewController: UIViewController {
    
    // MARK: - Variables
    private var cardShown = false
    private var lastDocumentSnapshot: DocumentSnapshot!
    private let viewModel: MapViewModel
    
    // MARK: - Outlets
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private lazy var mapViewWishCard = MapViewWishCard(delegate: self)
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = false
        mapView.delegate = self
        let mapGesture = UITapGestureRecognizer(target: self, action: #selector(hideCard(sender:)))
        mapGesture.cancelsTouchesInView = false
        mapView.addGestureRecognizer(mapGesture)
        mapView.register(WishMKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        return mapView
    }()
    
    private let updateButton = UIButtonFactory().background(color: UIColor.appColor(.primary))
        .set(image: Icons.Wish.refresh).tint(color: .white)
        .set(title: LocalizedText.Interesting.SHOW_NEARBY).title(color: .white).font(Fonts.Secondary)
        .corner(radius: Constants.Radius.card)
        .addTarget(#selector(handleUpdate))
        .content(inset: UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30))
        .build()
    
    // MARK: - LifeCycle
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
        viewModel.fetchWishes()
    }
    
    // MARK: - Actions
    @objc private func handleUpdate() {
        viewModel.fetchWishes()
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.reloadMapWithData = { annotations in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.showAnnotations(annotations, animated: true)
            self.lastDocumentSnapshot = self.viewModel.lastDocumentSnapshot
            self.view.endEditing(true)
            self.showHUD(type: .dismiss)
        }
        
        viewModel.showHUD = { [weak self] (type, text) in
            self?.showHUD(type: type, text: text)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)
        navigationItem.title = LocalizedText.Interesting.WISHES_NEARBY
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        [mapView, updateButton, mapViewWishCard].forEach { view.addSubview($0) }
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        updateButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        mapViewWishCard.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.trailing)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.bottom.equalTo(updateButton)
            make.height.greaterThanOrEqualTo(160)
        }
    }
}

// MARK: - MKMapView Delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let wishAnnotation = annotation as? WishAnnotation,
           let wishAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? WishMKAnnotationView {
            wishAnnotationView.annotation = wishAnnotation
            return wishAnnotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        delegate.hideKeyboard()
        
        if let view = view as? WishMKAnnotationView {
            deselectAllAnotations()
            view.activeBorder(true)
        }
        if let anotation = view.annotation as? WishAnnotation {
            let viewModel = self.viewModel.currentShowWishVMs.first { anotation.id == $0.id }
            if let viewModel = viewModel {
                showCardAnimated(model: viewModel)
            }
        }
    }
}

// MARK: - Wish Card Delegate
extension MapViewController: MapViewWishCardDelegate {
    func avatarAction(model: WishViewModel) {
        let uid = model.author.uid 
        viewModel.navigateProfile?(uid)
    }
    
    func detailAction(model: WishViewModel) {
        viewModel.navigateWish?(model, nil)
    }
}

// MARK: - Animations
extension MapViewController {
    
    @objc func hideCard(sender: UITapGestureRecognizer) {
        if !cardShown {
            return
        }
        let location = sender.location(in: mapView)
        var outside = true
        for annotation in mapView.annotations {
            let annotationView = mapView.view(for: annotation)
            if let annotationView = annotationView {
                if annotationView.frame.contains(location) {
                    outside = false
                    break
                }
            }
        }
        
        if outside {
            cardShown = false
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [weak self] in
                guard let self = self else { return }
                self.mapViewWishCard.snp.remakeConstraints { (make) in
                    make.leading.equalTo(self.view.snp.trailing)
                    make.width.equalToSuperview().multipliedBy(0.9)
                    make.bottom.equalTo(self.updateButton).offset(100)
                    make.height.greaterThanOrEqualTo(160)
                }
                self.view.layoutIfNeeded()
            }
            mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: false) }
            deselectAllAnotations()
        }
    }
    
    private func deselectAllAnotations() {
        mapView.annotations.forEach {
            if let wishView = mapView.view(for: $0) as? WishMKAnnotationView {
                wishView.activeBorder(false)
            }
        }
    }
    
    private func showCardAnimated(model: WishViewModel) {
        if !cardShown {
            mapViewWishCard.configure(viewModel: model)
            // resize card to fit content before animation
            mapViewWishCard.snp.updateConstraints { (make) in
                make.width.equalToSuperview().multipliedBy(0.9)
                make.height.greaterThanOrEqualTo(160)
            }
            view.layoutIfNeeded()
            cardShown = true
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [self] in
                mapViewWishCard.snp.remakeConstraints { (make) in
                    make.width.equalToSuperview().multipliedBy(0.9)
                    make.bottom.equalTo(updateButton).offset(10)
                    make.height.greaterThanOrEqualTo(160)
                    make.centerX.equalToSuperview()
                }
                view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [self] in
                mapViewWishCard.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.view.snp.bottom)
                    make.width.equalToSuperview().multipliedBy(0.9)
                    make.height.greaterThanOrEqualTo(160)
                    make.centerX.equalToSuperview()
                    
                }
                view.layoutIfNeeded()
            } completion: { [self] (_) in
                mapViewWishCard.configure(viewModel: model)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [self] in
                    mapViewWishCard.snp.remakeConstraints { (make) in
                        make.width.equalToSuperview().multipliedBy(0.9)
                        make.centerX.equalToSuperview()
                        make.bottom.equalTo(self.updateButton).offset(10)
                        make.height.greaterThanOrEqualTo(160)
                    }
                    view.layoutIfNeeded()
                }
            }
        }
    }
}

extension MapViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, let placeId = viewModel.placeId else { return }
        viewModel.searchWishes(onPage: 10, query: text, onPlace: placeId)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.cancelSearch()
    }
}
