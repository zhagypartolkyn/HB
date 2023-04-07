 

import UIKit
import SnapKit
import MapKit

class InterestingMapCell: UITableViewCell {
    
    // MARK: - Variables
    private var viewModels: [WishViewModel] = []
    public var isError: Bool = false
    
    // MARK: - Outlets
    private let mainView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: Constants.Radius.card)
        .build()
    
    private let titleLabel = UILabelFactory(text: LocalizedText.Interesting.WISHES_NEARBY)
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Heading3)
        .build()
    
    private let subtitleLabel = UILabelFactory(text: LocalizedText.Interesting.FIND_NEAR_WISH)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Secondary)
        .build()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.register(WishMKAnnotationView.self, forAnnotationViewWithReuseIdentifier: WishMKAnnotationView().cellIdentifier)
        mapView.layer.cornerRadius = Constants.Radius.card
        mapView.layer.masksToBounds = true
        mapView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        mapView.clipsToBounds = true
        return mapView
    }()
    
    private let darkerView = UIViewFactory()
        .background(color: UIColor.appColor(.primary))
        .alpha(0.5)
        .hide()
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.Interesting.CITY_ERROR)
        .font(Fonts.Heading3)
        .numberOf(lines: 0)
        .text(align: .center)
        .text(color: .white)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    public func configure(_ placeId: String?) {
        guard let placeId = placeId else { return }
        
        titleLabel.text = placeId == UserLocationType.world.rawValue ? "Желания на карте" : LocalizedText.Interesting.WISHES_NEARBY
        subtitleLabel.text = placeId == UserLocationType.world.rawValue ? "Найдите желания в любой точке мира": LocalizedText.Interesting.FIND_NEAR_WISH
        
        let query = Queries.Wish.map(placeId: placeId, lastDocumentSnapshot: nil)
        DB.fetchViewModels(model: Wish.self, viewModel: WishViewModel.self, query: query, limit: 10) { (result) in
            switch result {
            case .success((let wishVMs, _, _)):
                self.viewModels = wishVMs
                var nearByAnnotations: [MKAnnotation] = []
                
                for wishVM in wishVMs {
                    guard let geoPoint = wishVM.location.geoPoint else { return }
                        
                    let annotation = WishAnnotation(
                        id: wishVM.id,
                        type: wishVM.type,
                        title: wishVM.title,
                        subtitle: wishVM.username,
                        coordinate: CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude),
                        viewModel: wishVM
                    )
                    annotation.cover.kf.setImage(with: URL(string: wishVM.avatar), completionHandler:  { [self] _ in
                        nearByAnnotations.append(annotation)
                        mapView.showAnnotations(nearByAnnotations, animated: true)
                    })
                }
                self.showError(false)
            case .failure(_):
                self.showError(true)
            }
        }
    }
    
    // MARK: - Private Methods
    private func showError(_ status: Bool) {
        darkerView.isHidden = !status
        errorLabel.isHidden = !status
        isError = status
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(mainView)
        mainView.layer.applyCardShadow()
        
        mainView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        [mapView, titleLabel, subtitleLabel, darkerView].forEach{ mainView.addSubview($0) }
        
        mapView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-16)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(16)
        }
        
        [darkerView, errorLabel].forEach{ mapView.addSubview($0) }
        darkerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
    }
}

// MARK: - Map Delegate
extension InterestingMapCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let wishAnnotation = annotation as? WishAnnotation,
           let wishAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: WishMKAnnotationView().cellIdentifier) as? WishMKAnnotationView {
            wishAnnotationView.annotation = wishAnnotation
            return wishAnnotationView
        }
        return nil
    }
}
