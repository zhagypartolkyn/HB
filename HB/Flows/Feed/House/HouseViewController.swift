 

import UIKit
import SwiftUI

class HouseViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: HouseViewModel
    private let fullHistoryViewModel: FullHistoryViewModel
    private let wishDetailViewModel: WishDetailViewModel
    private lazy var contentView = UIHostingController(rootView: HouseView(viewModel: viewModel, fullHistoryViewModel: fullHistoryViewModel, wishDetailViewModel: wishDetailViewModel))
    
    private lazy var userLocation = UserLocation(delegate: self, vc: self)
    private lazy var cityPicker = CityPicker(delegate: self, vc: self)
    private var placeId: String?
    
    // MARK: - LifeCycle
    init(viewModel: HouseViewModel, fullHistoryViewModel: FullHistoryViewModel, wishDetailViewModel: WishDetailViewModel) {
        self.viewModel = viewModel
        self.fullHistoryViewModel = fullHistoryViewModel
        self.wishDetailViewModel = wishDetailViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
        userLocation.getPlaceId()
        
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().selectionStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newPlaceId = userLocation.getOnlyPlaceId()
        if let placeId = placeId, placeId != newPlaceId {
            userLocation.getPlaceId()
        }
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.showMore = { [weak self] (wishVM) in
            guard let self = self else { return  }
            self.handleWishMore(wishVM: wishVM, deleteCompletionHandler: nil, exitCompletionHandler: nil)
        }
    }
    
    // MARK: - Actions
    @objc private func handleSearch() {
        guard let placeId = placeId else { return }
        viewModel.navigateSearch?(placeId)
    }
    
    @objc private func handleMap() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Весь мир", style: .default, handler: { (alert) in
            self.userLocation.getPlaceId(world: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Мое местоположение", style: .default, handler: { (alert) in
            self.userLocation.getPlaceId(world: false)
        }))
        
        alert.addAction(UIAlertAction(title: "Выбрать город", style: .default, handler: { (alert) in
            self.cityPicker.show()
        }))
    
        self.present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        }
    }
    
    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.titleView = LogoTitleView()
        view.backgroundColor = .systemBackground
        
        let leftButton = UIBarButtonItem(image: Icons.General.search, style: .plain, target: self, action: #selector(handleSearch))
        leftButton.tintColor = UIColor.appColor(.textPrimary)
        navigationItem.leftBarButtonItem = leftButton
        
//        let rightButton = UIBarButtonItem(image: Icons.General.map, style: .plain, target: self, action: #selector(handleMap))
//        rightButton.tintColor = UIColor.appColor(.textPrimary)
//        navigationItem.rightBarButtonItem = rightButton
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        contentView.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}

// MARK: - Location
extension HouseViewController: UserLocationFinderDelegate, CityPickerDelegate {
    func didAllowLocationPermission() {
        
    }
    
    func didDeniedPermission() {
        
    }
    
    func update(placeId: String, city: String, type: UserLocationType) {
        showWishesWith(placeId: placeId, city: city,type: type)
    }
    
    func updateCity(placeId: String, city: String) {
        showWishesWith(placeId: placeId, city: city, type: .city)
    }
    
    private func showWishesWith(placeId: String, city: String, type: UserLocationType) {
        self.placeId = placeId
        contentView.rootView.viewModel.setPlaceId(placeId, title: city)
        
        // query for history
        fullHistoryViewModel.query = Queries.History.place(withId: placeId)
        fullHistoryViewModel.resetAndFetch()
    }
}

// MARK: - Wish Detail
extension HouseViewController {
    
    // MARK: - More Alert
    func handleWishMore(wishVM: WishViewModel, deleteCompletionHandler: (() -> Void)?, exitCompletionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: LocalizedText.profile.SETTINGS, message: wishVM.title, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: LocalizedText.alert.shareWish, style: .default, handler: { (_) in
            let vc = UIActivityViewController(activityItems: [URL(string: "https://wanty.io?wish=" + wishVM.id)!], applicationActivities: [])
            self.present(vc, animated: true)
        }))
        
        if wishVM.isMyWish {
            alert.addAction(UIAlertAction(title: LocalizedText.alert.completeWish, style: .default, handler: { (_) in
                self.handleComplete(wishVM: wishVM)
            }))
            
            alert.addAction(UIAlertAction(title: LocalizedText.alert.deleteWish, style: .destructive, handler: { (_) in
                self.handleDelete(wishVM: wishVM, completionHandler: deleteCompletionHandler)
            }))
        } else {
            if wishVM.isIParticipate {
                alert.addAction(UIAlertAction(title: LocalizedText.alert.exitWish, style: .destructive, handler: { (_) in
                    self.handleWish(wishVM: wishVM, completionHandler: exitCompletionHandler)
                }))
            }
            alert.addAction(UIAlertAction(title: LocalizedText.alert.complainOnWish, style: .destructive, handler: { (_) in
                let reportObject = ReportObject(id: wishVM.id, type: ReportObjectType.wish.rawValue, uid: wishVM.uid)
                self.viewModel.navigateReport?(reportObject)
            }))
        }

        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delete Alert
    private func handleDelete(wishVM: WishViewModel, completionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: LocalizedText.alert.deleteWishTitle, message: wishVM.title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedText.General.yes, style: .destructive, handler: { (_) in
            self.showHUD()
            self.wishDetailViewModel.deleteWish(id: wishVM.id) { [self] (result) in
                switch result {
                case .success(_): showHUD(type: .success, text: LocalizedText.alert.deleteWishSuccess)
                case .failure(let error): showHUD(type: .error, text: "Error with deleting \(error.localizedDescription)")
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Exit Alert
    private func handleWish(wishVM: WishViewModel, completionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: LocalizedText.alert.exitWishSubtitle, message: LocalizedText.alert.exitWishTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedText.alert.exitWish, style: .destructive, handler: { [self] (_) in
            showHUD()
            
            self.wishDetailViewModel.exitWish(id: wishVM.id) { (result) in
                switch result {
                case .success(_): showHUD(type: .success, text: LocalizedText.alert.exitWishSuccess)
                case .failure(let error): showHUD(type: .error, text: "Error with exiting \(error.localizedDescription)")
                }
            }
            
        }))
        self.present(alert, animated: true)
    }
    
    // MARK: - Complete Alert
    private func handleComplete(wishVM: WishViewModel) {
        let alert = UIAlertController(title: LocalizedText.alert.completionWish, message: LocalizedText.alert.completionWishTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedText.General.complete, style: .default, handler: { (_) in
            
            if wishVM.isGroupWish {
                self.showHUD()
                self.wishDetailViewModel.completeGroupWish(id: wishVM.id) { (text) in
                    self.showHUD(type: .success, text: text)
                }
            } else {
                self.viewModel.navigateComplete?(wishVM)
            }
            
        }))
        self.present(alert, animated: true)
    }
    
}
