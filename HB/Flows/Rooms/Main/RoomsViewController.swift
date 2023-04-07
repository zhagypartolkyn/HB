 

import UIKit
import Firebase

class RoomsViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: RoomsViewModel
    private let wishDetailViewModel: WishDetailViewModel
    
    // MARK: - Outlets
    private let refresher = UIRefreshFactory().addTarget(#selector(handleRefresher)).build()
    
    public lazy var tableView = GenericTableView(
        items: [RoomViewModel](),
        configure: { (cell: RoomCell, roomVM) in
            cell.configure(viewModel: roomVM)
        },
        selectHandler: { (roomVM) in
            self.viewModel.navigateMessage?(roomVM.id)
        },
        skeletonCell: SkeletonWishCell.self,
        refresher: refresher,
        loadMore: {
            self.viewModel.loadMore()
        },
        type: .room,
        edit: editRoom
    )
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.room)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.error.rooms)
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
    init(viewModel: RoomsViewModel, wishDetailViewModel: WishDetailViewModel) {
        self.viewModel = viewModel
        self.wishDetailViewModel = wishDetailViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        viewModelBinding()
        
        if let wish = viewModel.wishVM {
            navigationItem.title = wish.title
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.roomVMs.isEmpty { viewModel.loadMore() }
    }
    
    // MARK: - Actions
    @objc private func handleRefresher() {
        DispatchQueue.main.asyncAfter(deadline: (.now() + 0.5)) { [weak self] in
            self?.refresher.endRefreshing()
        }
    }
    
    public func isTableEmpty() -> Bool {
        return tableView.items.isEmpty
    }
    
    // MARK: - Methods
    private func viewModelBinding() {
        viewModel.reloadWithData = {[self] (roomVMs) in
            tableView.update(items: roomVMs)
        }
        
        viewModel.showPlaceholderView = { [self] bool in
            errorStackView.isHidden = !bool
        }
    }
    
    private func editRoom(roomVM: RoomViewModel) {
        if roomVM.author.uid == DB.Helper.uid {
            if roomVM.typeIsGroup {
                self.wishDetailViewModel.deleteWish(id: roomVM.wishId) { [self] (result) in
                    switch result {
                    case .success(_): showHUD(type: .success, text: LocalizedText.alert.deleteWishSuccess)
                    case .failure(let error): showHUD(type: .error, text: "Error with deleting \(error.localizedDescription)")
                    }
                }
            } else {
                viewModel.deleteSingleWishRoom(roomVM: roomVM) { [self] (result) in
                    switch result {
                    case .success(_): showHUD(type: .success, text: LocalizedText.alert.deleteWishSuccess)
                    case .failure(let error): showHUD(type: .error, text: "Error with deleting \(error.localizedDescription)")
                    }
                }
            }
            
        } else {
            self.wishDetailViewModel.exitWish(id: roomVM.wishId) { [self] (result) in
                switch result {
                case .success(_): showHUD(type: .success, text: LocalizedText.alert.exitWishSuccess)
                case .failure(let error): showHUD(type: .error, text: "Error with exiting \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.backgroundSecondary)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = LocalizedText.tabBar.MESSAGES
        
        [tableView, errorStackView].forEach{ view.addSubview($0) }
        
        errorStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        errorImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(200)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

// MARK: - ErrorView Delegate
extension RoomsViewController: ErrorViewDelegate {
    func handleButton() {
//        navigationController?.pushViewController(CityListViewController(), animated: true)
    }
}
