 

import UIKit
import SnapKit

class CompleteViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: CompleteViewModel
    
    // MARK: - Outlets
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WishCompleteCell.self, forCellReuseIdentifier: WishCompleteCell.cellIdentifier())
        tableView.backgroundColor = UIColor.appColor(.background)
        tableView.contentInset.bottom = 80
        return tableView
    }()
    
    private let createConnectButton = UIButtonFactory(style: .active).set(title: LocalizedText.wish.CREATE_CONNECTS).addTarget(#selector(handleConnects)).build()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        viewModelBinding()
        viewModel.loadParticipants()
    }
    
    init(viewModel: CompleteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func handleConnects() {
        showHUD()
        viewModel.createConnects()
    }
    
    // MARK: - Methods
    private func viewModelBinding() {
        viewModel.reloadData = { [self] in
            tableView.reloadData()
        }
        
        viewModel.showHUD = { [self] (type, text) in
            showHUD(type: type, text: text)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.title = LocalizedText.wish.END_WISH
        navigationItem.largeTitleDisplayMode = .never
        
        [tableView, createConnectButton].forEach { view.addSubview($0) }
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        createConnectButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.centerX.equalToSuperview()
        }
    }
    
}

// MARK: - Table View Delegate
extension CompleteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.wishParticipants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WishCompleteCell.cellIdentifier(), for: indexPath) as! WishCompleteCell
        cell.avatarImageView.kf.indicatorType = .activity
        cell.avatarImageView.kf.setImage(with: URL(string: viewModel.wishParticipants[indexPath.row].avatar))
        cell.usernameLabel.text = viewModel.wishParticipants[indexPath.row].username
        if viewModel.markedCells[indexPath.row] != nil {
            cell.radioButton.image = Icons.Profile.activeRadiobutton
        } else {
            cell.radioButton.image = Icons.Profile.radiobutton
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        82
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WishCompleteCell
        let isMarkedCell = viewModel.markedCells[indexPath.row] != nil
        
        viewModel.markedCells[indexPath.row] = isMarkedCell ? nil : viewModel.wishParticipants[indexPath.row].uid
        cell.radioButton.image = isMarkedCell ? Icons.Profile.radiobutton : Icons.Profile.activeRadiobutton
    }
    
}
