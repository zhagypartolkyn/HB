 

import UIKit
import SnapKit
import Kingfisher

class ProfileConnectsViewController: UIViewController {
    
    // MARK: - Variables
    let viewModel: ProfileConnectsViewModel
    
    // MARK: - Outlets
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ConnectTableViewCell.self, forCellReuseIdentifier: ConnectTableViewCell.cellIdentifier())
        return tableView
    }()
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.connects)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.error.connects)
        .font(Fonts.Semibold.Paragraph)
        .text(align: .center)
        .text(color: UIColor.appColor(.textSecondary))
        .numberOf(lines: 0)
        .build()
    
    private lazy var errorStackView = UIStackViewFactory(views: [errorImageView, errorLabel])
        .axis(.vertical)
        .spacing(12)
        .distribution(.fill)
        .alignment(.center)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
        viewModel.getConnects()
    }

    init(viewModel: ProfileConnectsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func viewModelBinding() {
        viewModel.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
        
        errorStackView.isHidden = viewModel.loadedConnects.isEmpty
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)
        tableView.backgroundColor = UIColor.appColor(.background)
        navigationItem.title = LocalizedText.wish.CONNECTS
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(errorStackView)
        
        errorStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        errorImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(200)
        }
    }
    
}

// MARK: - Table View
extension ProfileConnectsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.loadedConnects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConnectTableViewCell.cellIdentifier()) as! ConnectTableViewCell
        cell.avatarImageView.kf.indicatorType = .activity
        let user = viewModel.loadedConnects[indexPath.row]
        cell.avatarImageView.kf.setImage(with: URL(string: user.avatar))
        cell.usernameLabel.text = user.username
        cell.connectsLabel.text = String.localizedStringWithFormat(LocalizedText.wish.CONNECTS_COUNT, String(viewModel.completedWishesAssociation[user.uid]!))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        82
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.navigateProfile?(viewModel.loadedConnects[indexPath.row].uid)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !viewModel.performingRequest, !viewModel.lastPage, !viewModel.loadedConnects.isEmpty {
            let scroollViewHeight = scrollView.frame.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < scroollViewHeight {
                viewModel.loadUsers()
            }
        }
    }
    
}
