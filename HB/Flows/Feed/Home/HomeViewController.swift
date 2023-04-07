 

import Tabman
import Pageboy

class HomeViewController: TabmanViewController {

    // MARK: - Variables
    private let viewModel: HomeViewModel
    private let cityViewModel: CityViewModel
    private let topWishesViewModel: TopWishesViewModel
    private let fullHistoryViewModel: FullHistoryViewModel
    private let wishDetailViewModel: WishDetailViewModel
    
    public lazy var viewControllers: [UIViewController] = [
        TopWishesViewController(viewModel: topWishesViewModel, wishDetailViewModel: wishDetailViewModel),
        CityViewController(viewModel: cityViewModel, wishDetailViewModel: wishDetailViewModel),
        CityMomentsViewController(fullHistoryViewModel: fullHistoryViewModel)
    ]
    
    private var cityText = "Город"
    private var placeId: String?
    
    private lazy var userLocation = UserLocation(delegate: self, vc: self)
    private lazy var cityPicker = CityPicker(delegate: self, vc: self)
    let bar = TMBar.ButtonBar()
    
    // MARK: - LifeCycle
    init(viewModel: HomeViewModel ,cityViewModel: CityViewModel, fullHistoryViewModel: FullHistoryViewModel, wishDetailViewModel: WishDetailViewModel, topWishesViewModel: TopWishesViewModel) {
        self.viewModel = viewModel
        self.cityViewModel = cityViewModel
        self.fullHistoryViewModel = fullHistoryViewModel
        self.wishDetailViewModel = wishDetailViewModel
        self.topWishesViewModel = topWishesViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        userLocation.getPlaceId()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newPlaceId = userLocation.getOnlyPlaceId()
        if let placeId = placeId, placeId != newPlaceId {
            userLocation.getPlaceId()
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
        
        self.dataSource = self
       
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.interButtonSpacing = 0
        bar.layout.separatorColor = .red
        bar.layout.alignment = .centerDistributed
        bar.backgroundView.style = .blur(style: .regular)
        bar.buttons.customize { (button) in
           
            button.tintColor = UIColor.appColor(.textPrimary)
            button.selectedTintColor =  UIColor.appColor(.primary)

            button.snp.makeConstraints { (make) in
                make.width.equalTo(140)
            }
            
        }
        addBar(bar, dataSource: self, at: .top)
    }
    
}

// MARK: - Location
extension HomeViewController: UserLocationFinderDelegate, CityPickerDelegate {
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
        cityText = city
        bars[0].reloadData(at: 0...2, context: .full)
        if let vc = viewControllers[1] as? CityViewController {
            vc.userLocation.getPlaceId()
        }
        
        if let vc = viewControllers[0] as? TopWishesViewController {
            vc.userLocation.getPlaceId()
        }
        
        // query for history
        fullHistoryViewModel.query = Queries.History.place(withId: placeId)
        fullHistoryViewModel.resetAndFetch()
    }
}

// MARK: - TabMan
extension HomeViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        if index == 1{
            let item = TMBarItem(title: cityText)
            return item
        }else {
            let title = index == 2 ? "Истории" : "Топ"
            return TMBarItem(title: title)
        }
    }
}
