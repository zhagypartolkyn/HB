

import UIKit
import FirebaseFirestore
import Mantis
import MapKit

class AddWishViewController: UIViewController {
    
    // MARK: - Variables
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self, withVideo: false)
    private lazy var userLocationFinder = UserLocation(delegate: self, vc: self)
    private let viewModel: AddWishViewModel
    private var randomWishes = [RandomWish]()
    
    // MARK: - Outlets
    private let mainView = AddWishView()
    
    // MARK: - LifeCycle
    init(viewModel: AddWishViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
    }
    
    override func loadView() {
        view = mainView
        mainView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setupUser()
        if viewModel.wish.location.countryCode == nil {
            askLocationPermission()
        }
    }
    
//    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if motion == .motionShake { showRandomWish() }
//    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        viewModel.showHUD = { [self] (type, text) in
            showHUD(type: type, text: text)
        }
        
        viewModel.navigateBack = { [self] in
            handleBack()
        }
    }
    
    // MARK: - Actions
    @objc private func handleBack() {
        tabBarController?.selectedIndex = 4
        resetController()
    }
    
    @objc private func handleAdd() {
        let vc = AddWishTypeViewController(delegate: self)
        vc.modalPresentationStyle = .fullScreen
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func showRandomWish() {
        if randomWishes.isEmpty {
            DB.fetchModels(model: RandomWish.self, query: Ref.Fire.randomWishes) { (result) in
                switch result {
                case .success((let randomWishes, _, _)):
                    self.randomWishes = randomWishes.shuffled()
                    self.showRandomWish()
                    self.enableAddButton(true)
                case .failure(let error):
                    self.showHUD(type: .error, text: error.localizedDescription)
                    self.enableAddButton(false)
                }
            }
        } else {
            guard let randomWishData = randomWishes.first else { return }
            randomWishes.removeFirst()
            randomWishes.append(randomWishData)
            mainView.configureWithRandom(data: randomWishData)
            enableAddButton(true)
        }
    }
    
    private func askLocationPermission() {
        userLocationFinder.get() { [self] (result) in
            switch result {
            case .success(let location):
                viewModel.wish.location = location
                viewModel.wish.location.geoPoint = nil
                mainView.showPermission(false)
            case .failure(_):
                mainView.showPermission(true)
            }
        }
    }
    
    private func resetController() {
        enableAddButton(false)
        mainView.resetView()
        viewModel.resetWishModel()
        view.endEditing(true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)
        navigationItem.title = LocalizedText.addWish.NEW_WISH
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.General.arrow_back, style: .plain, target: self, action: #selector(handleBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedText.logInPage.email.next, style: .done, target: self, action: #selector(handleAdd))
        enableAddButton(false)
    }
    
}

// MARK: - MainView Delegate
extension AddWishViewController: AddWishViewDelegate {
    func enableAddButton(_ enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }

    func pickerAction() {
        imagePicker.presentAlert()
    }
    
    func showOnMap(_ enable: Bool) {
        if enable { viewModel.navigateMap?(self) }
        viewModel.wish.showOnMap = enable
    }
    
    func checkPermission() {
        userLocationFinder.get { (_) in }
    }
}

// MARK: - ImagePicker Delegate
extension AddWishViewController: ImagePickerDelegate {
    func didSelect(url: URL) {}

    func didSelect(image: UIImage) {
        let cropViewController = Mantis.cropViewController(image: image , config: Mantis.Config())
        cropViewController.delegate = self
        cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1.0 / 0.7)
        DispatchQueue.main.async { [weak self] in
            self?.present(cropViewController, animated: true)
        }
    }
}

// MARK: - ImageCropper Delegate
extension AddWishViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        mainView.configureCover(image: cropped)
        dismiss(animated: true)
    }

    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
}

// MARK: - UserLocationFinder Delegate
extension AddWishViewController: UserLocationFinderDelegate {
    func update(placeId: String, city: String, type: UserLocationType) {
        
    }
    
    func didAllowLocationPermission() {
        mainView.showPermission(false)
        askLocationPermission()
    }
    
    func didDeniedPermission() {
        mainView.showPermission(true)
    }
}

// MARK: - HandleAddCoordinate Delegate
extension AddWishViewController: HandleAddCoordinate {
    func actionAdd(location: CLLocationCoordinate2D?) {
        if let location = location {
            viewModel.wish.location.geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
            mainView.recreateAnnotation(location)
        } else if viewModel.wish.location.geoPoint == nil {
            mainView.showOnMapSwitch.isOn = false
            viewModel.wish.showOnMap = false
        }
    }
}

// MARK: - WishType Delegate
extension AddWishViewController: AddWishTypeViewControllerDelegate {
    func createWishAction(type: WishType) {
        let wishData = mainView.fetchData()
        viewModel.wish.type = type.rawValue
        viewModel.create(title: wishData.title, description: wishData.description, image: wishData.image)
    }
}
