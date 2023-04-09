 
import UIKit

class CityMomentsViewController: UIViewController {
    
    // MARK: - Variables
    private var fullHistoryViewModel: FullHistoryViewModel
    var viewWillAppear: Bool = false
    
    // MARK: - Outlets
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: HistoryCell.cellIdentifier())
        return collectionView
    }()
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.moments)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.error.city_moments)
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
    init(fullHistoryViewModel: FullHistoryViewModel) {
        self.fullHistoryViewModel = fullHistoryViewModel
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillAppear = false
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        fullHistoryViewModel.reloadDataParent = {
            self.collectionView.reloadData()
            self.errorStackView.isHidden = !self.fullHistoryViewModel.historyVMs.isEmpty
        }
    }
    
    public func isTableEmpty() -> Bool {
        return fullHistoryViewModel.historyVMs.isEmpty
    }
    
    // MARK: - Setup UI
    private func setupUI() {
//        view.backgroundColor = UIColor.appColor(.background)
        navigationItem.largeTitleDisplayMode = .never
        
        [collectionView, errorStackView].forEach { view.addSubview($0) }
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        errorStackView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

}

// MARK: - Collection Delegate
extension CityMomentsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !fullHistoryViewModel.isLoading, fullHistoryViewModel.canLoadMore, !fullHistoryViewModel.historyVMs.isEmpty {
            let scroollViewHeight = scrollView.frame.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < scroollViewHeight {
                fullHistoryViewModel.fetchHistories()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fullHistoryViewModel.historyVMs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCell.cellIdentifier(), for: indexPath) as! HistoryCell
        cell.configure(viewModel: fullHistoryViewModel.historyVMs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = IndexPath(row: indexPath.row, section: 0)

        fullHistoryViewModel.navigateHistory?(index)
        
        if fullHistoryViewModel.historyVMs.count - 1 == index.row {
            fullHistoryViewModel.fetchHistories()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = Double((collectionView.bounds.width / 3) - 16)
        return .init(width: totalWidth, height: 165)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 60, right: 16)
    }
    
}
