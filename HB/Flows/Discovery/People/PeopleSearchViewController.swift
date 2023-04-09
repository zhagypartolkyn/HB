 

import UIKit

class PeopleSearchViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: PeopleSearchViewModel
    private var text: String = ""
    
    // MARK: - Outlets
    private let refresher = UIRefreshFactory().addTarget(#selector(refreshing)).build()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = LocalizedText.feed.search
        return searchController
    }()
    
    private lazy var tableView = GenericTableView(items: [UserViewModel](), configure: { (cell: PeopleSearchCell, user) in
        cell.configure(avatarUrl: user.avatar, username: user.name)
    }, selectHandler: { (userVM) in
        self.viewModel.navigateProfile?(userVM.uid)
    }, skeletonCell: SkeletonWishCell.self, refresher: refresher, loadMore: {
        self.searchMore()
    })
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.city)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: "Пользователь не найден :(")
        .font(Fonts.Semibold.Paragraph)
        .text(align: .center)
        .text(color: UIColor.appColor(.textPrimary))
        .numberOf(lines: 0)
        .build()
    
    private lazy var errorStackView = UIStackViewFactory(views: [errorImageView, errorLabel])
        .axis(.vertical)
        .spacing(32)
        .distribution(.fill)
        .alignment(.center)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    init(viewModel: PeopleSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    
    // MARK: - Actions
    @objc private func refreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refresher.endRefreshing()
        }
    }
    
    // MARK: - Methods
    private func searchMore() {
        if !text.isEmpty {
            self.viewModel.searchUsers(query: self.text) { (wishVMs) in
                self.showHUD(type: .dismiss)
                self.tableView.update(items: wishVMs)
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.backgroundSecondary)
        navigationItem.title = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.keyboardDismissMode = .onDrag
        
        [tableView, errorStackView].forEach{ view.addSubview($0) }
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        errorStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Search Updating
extension PeopleSearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        showHUD()
        
        guard let text = searchBar.text else { return }
        self.text = text
        self.viewModel.userVMs = []
        viewModel.searchUsers(query: text) { (userVMs) in
            self.showHUD(type: .dismiss)
            self.tableView.update(items: userVMs)
            self.errorStackView.isHidden = !userVMs.isEmpty
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.showHUD(type: .dismiss)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.searchTextField.becomeFirstResponder()
    }
}
