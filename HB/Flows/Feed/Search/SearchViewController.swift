 
import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: SearchViewModel
    private let wishDetailViewModel: WishDetailViewModel
    private let placeId: String
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
    
    private lazy var tableView = GenericTableView(items: [WishViewModel](), configure: { (cell: WishCell, wish) in
        cell.configure(model: wish)
        cell.delegate = self
    }, selectHandler: { (wishVM) in
        self.detailAction(viewModel: wishVM)
    }, skeletonCell: SkeletonWishCell.self, refresher: refresher, loadMore: {
        self.searchMore()
    })
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.city)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.error.search)
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
    init(viewModel: SearchViewModel, wishDetailViewModel: WishDetailViewModel, placeId: String) {
        self.viewModel = viewModel
        self.wishDetailViewModel = wishDetailViewModel
        self.placeId = placeId
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
            self.viewModel.searchWishes(query: self.text, placeId: self.placeId) { (wishVMs) in
                self.showHUD(type: .dismiss)
                self.tableView.update(items: wishVMs)
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.backgroundSecondary)
        navigationItem.title = "Поиск по желаниям"
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
        
        errorImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(200)
        }
    }
}

// MARK: - Search Updating
extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        showHUD()
        
        guard let text = searchBar.text else { return }
        self.text = text
        self.viewModel.searchWishVMs = []
        viewModel.searchWishes(query: text, placeId: placeId) { (wishVMs) in
            self.showHUD(type: .dismiss)
            self.tableView.update(items: wishVMs)
            self.errorStackView.isHidden = !wishVMs.isEmpty
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.showHUD(type: .dismiss)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.searchTextField.becomeFirstResponder()
    }
}

// MARK: - WishCell Delegate
extension SearchViewController: WishCellDelegate {
    func upVoteAction(viewModel: WishViewModel, userWhoLiked: String, touches: Int) {
        if touches > 1 {
            self.showHUD(type: .success, text: LocalizedText.wish.VOTE_DOUBLE)
        } else {
            wishDetailViewModel.upVote(viewModel: viewModel, userUid: DB.Helper.uid) { (result) in
                switch result {
                case .success(let check) :
                    if check {
                        self.showHUD(type: .success, text: "UpVoting went successfull")
                    } else {
                        self.showHUD(type: .success, text: LocalizedText.wish.VOTE_UP)
                    }
                case .failure(let error): print("DEBUG: Upvoting went wrong \(error.localizedDescription)")
                }
            }
        }
    }
    
    func downVoteAction(viewModel: WishViewModel, userWhoDisliked: String, touches: Int) {
        if touches > 1 {
            self.showHUD(type: .success, text: LocalizedText.wish.VOTE_DOUBLE)
        } else {
            wishDetailViewModel.downVote(viewModel: viewModel, userUid: DB.Helper.uid) { (result) in
                switch result {
                case .success(let check ):
                    if check {
                        self.showHUD(type: .success, text: LocalizedText.wish.VOTE_DOWN)
                    } else {
                        self.showHUD(type: .success, text: LocalizedText.wish.VOTE_DOUBLE)
                    }
                case .failure(let error): print("DEBUG: Downvoting went wrong \(error.localizedDescription)")
                }
            }
        }
    }
    
    func avatarAction(viewModel: WishViewModel) {
        self.viewModel.navigateProfile?(viewModel.uid)
    }
    
    func moreAction(viewModel: WishViewModel) {
        handleWishMore(wishVM: viewModel, deleteCompletionHandler: nil, exitCompletionHandler: nil)
    }
    
    func detailAction(viewModel: WishViewModel) {
        self.viewModel.navigateWish?(viewModel, nil)
    }
}

// MARK: - Wish Detail
extension SearchViewController {
    
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
