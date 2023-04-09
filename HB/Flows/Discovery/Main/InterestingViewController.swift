//
 

import UIKit

class InterestingViewController: UIViewController {
    
    // MARK: - Variables
    private var placeId: String?
    private let viewModel: InterestingViewModel
    private let fullHistoryViewModel: FullHistoryViewModel
    private lazy var userLocation = UserLocation(delegate: self, vc: self)
    private lazy var cityPicker = CityPicker(delegate: self, vc: self)
    
    // MARK: - Outlets
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.appColor(.backgroundSecondary)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        
        tableView.register(InterestingMapCell.self, forCellReuseIdentifier: InterestingMapCell.cellIdentifier())
        tableView.register(InterestingPeopleCell.self, forCellReuseIdentifier: InterestingPeopleCell.cellIdentifier())
        tableView.register(InterestingHistoriesCell.self, forCellReuseIdentifier: InterestingHistoriesCell.cellIdentifier())
        tableView.register(InterestingNewbieCell.self, forCellReuseIdentifier: InterestingNewbieCell.cellIdentifier())
        tableView.register(InterestingStarCell.self, forCellReuseIdentifier: InterestingStarCell.cellIdentifier())
        return tableView
    }()
    
    // MARK: - LifeCycle
    init(viewModel: InterestingViewModel, fullHistoryViewModel: FullHistoryViewModel) {
        self.viewModel = viewModel
        self.fullHistoryViewModel = fullHistoryViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
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
    
    override func loadView() {
        self.view = tableView
    }
    
    // MARK: - Actions
    @objc private func handleLocation() {
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
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = LocalizedText.tabBar.INTERESTING
        
//        let rightButton = UIBarButtonItem(image: Icons.General.map, style: .plain, target: self, action: #selector(handleLocation))
//        rightButton.tintColor = UIColor.appColor(.textPrimary)
//        navigationItem.rightBarButtonItem = rightButton
    }
    
}

// MARK: - Table Delegate
extension InterestingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let placeId = placeId else { return }
        switch indexPath.section {
        case 1:
            if let cell = tableView.cellForRow(at: indexPath) as? InterestingMapCell, !cell.isError {
                viewModel.navigateCity?(placeId)
            }
        case 2:
            if let cell = tableView.cellForRow(at: indexPath) as? InterestingPeopleCell, !cell.isError {
                viewModel.navigatePeople?(placeId)
            }
        default: break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: InterestingStarCell.cellIdentifier()) as! InterestingStarCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.configure(placeId)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: InterestingMapCell.cellIdentifier()) as! InterestingMapCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure(placeId)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: InterestingPeopleCell.cellIdentifier()) as! InterestingPeopleCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure(placeId)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: InterestingHistoriesCell.cellIdentifier()) as! InterestingHistoriesCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure(placeId, viewModel: viewModel, fullHistoryViewModel: fullHistoryViewModel)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: InterestingNewbieCell.cellIdentifier()) as! InterestingNewbieCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure(placeId)
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: InterestingMapCell.cellIdentifier()) as! InterestingMapCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure(placeId)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250
        } else {
            return 294
        }
    }
}

// MARK: - Newbie Delegate
extension InterestingViewController: InterestingNewbieCellDelegate {
    func didSelect(uid: String) {
        viewModel.navigateProfile?(uid)
    }
}

// MARK: - Star Delegate
extension InterestingViewController: InterestingStarCellDelegate {
    func didChoose(uid: String) {
        viewModel.navigateProfile?(uid)
    }
}

// MARK: - Location
extension InterestingViewController: UserLocationFinderDelegate, CityPickerDelegate {
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
        self.navigationItem.title = LocalizedText.tabBar.INTERESTING
        self.placeId = placeId
        self.tableView.reloadData()
    }
}
