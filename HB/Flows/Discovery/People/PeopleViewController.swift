//
 

import UIKit
import FirebaseFirestore
import SkeletonView
import SVProgressHUD

class PeopleViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: PeopleViewModel
    private let cellSpacing: CGFloat = 16
    
    // MARK: - Outlets
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        layout.itemSize = CGSize(width: (view.frame.width - cellSpacing * 3) / 2, height: 186)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
        collectionView.register(PeopleCell.self, forCellWithReuseIdentifier: PeopleCell.cellIdentifier())
        collectionView.register(PeopleSkeletonCell.self, forCellWithReuseIdentifier: PeopleSkeletonCell.cellIdentifier())
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refresher
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isSkeletonable = true
        return collectionView
    }()
    
    private let errorView: ErrorView = {
        let view = ErrorView()
        view.isHidden = true
        view.configureView(type: .chats)
        return view
    }()
    
    private let refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(setupPeople), for: .valueChanged)
        return refresher
    }()
    
    // MARK: - Life Cycle
    init(viewModel: PeopleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelBinding()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.models.isEmpty { setupPeople() }
    }
    
    // MARK: - Actions
    @objc private func handleSearch() {
        viewModel.navigateSearch?()
    }
    
    @objc private func setupPeople() {
        if viewModel.models.isEmpty {
            collectionView.showAnimatedSkeleton()
            viewModel.getUsers()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            collectionView.refreshControl!.endRefreshing()
        }
    }
    
    // MARK: - Methods
    private func viewModelBinding() {
        viewModel.reloadDataCallback = { [self] in
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }
        viewModel.refreshCallback = {[self] in refresher.endRefreshing()}
        viewModel.hideSkeleton = { [self] in
            if self.collectionView.isSkeletonActive {
                self.collectionView.hideSkeleton()
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        navigationItem.title = LocalizedText.Interesting.PEOPLE
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = UIColor.appColor(.backgroundSecondary)
        
        let rigthButton = UIBarButtonItem(image: Icons.General.search, style: .plain, target: self, action: #selector(handleSearch))
        rigthButton.tintColor = UIColor.appColor(.textPrimary)
        navigationItem.rightBarButtonItem = rigthButton
        
        view.addSubview(errorView)
        errorView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
    }

}

// MARK: - CollectionView Skeleton Delegate
extension PeopleViewController: SkeletonCollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.models.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeopleCell.cellIdentifier(), for: indexPath) as! PeopleCell
        cell.setupCell(withModel: viewModel.models[indexPath.row])
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.batchSize
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        PeopleSkeletonCell.cellIdentifier()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !viewModel.performingRequest, !viewModel.lastPage, !viewModel.models.isEmpty {
            let scroollViewHeight = scrollView.frame.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < scroollViewHeight {
                viewModel.getUsers()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.navigateProfile?(viewModel.models[indexPath.item].uid)
    }
}
