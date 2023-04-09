 

import UIKit

class WishMomentsViewController: UIViewController {
    
    private var viewModel: FullWishViewModel
    private var fullHistoryViewModel: FullHistoryViewModel
    private lazy var isShowAddCell: Bool = viewModel.wishVM.isIParticipate || viewModel.wishVM.isMyWish
    
    // MARK: - Outlets
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AddHistoryCell.self, forCellWithReuseIdentifier: AddHistoryCell.cellIdentifier())
        collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: HistoryCell.cellIdentifier())
        return collectionView
    }()
    
    private let errorImageView = UIImageViewFactory(image: Icons.Error.moments)
        .content(mode: .scaleAspectFit)
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.error.moments)
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
    
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self, withVideo: true)
    
    init(viewModel: FullWishViewModel, fullHistoryViewModel: FullHistoryViewModel) {
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
        viewModelBinding()
        fullHistoryViewModel.fetchHistories()
    }
    
    private func viewModelBinding() {
        fullHistoryViewModel.reloadDataParent = {
            self.collectionView.reloadData()
        }
        
        if !fullHistoryViewModel.hasHistories && !viewModel.wishVM.isMyWish {
            self.errorStackView.isHidden = false
        }

    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)
        navigationItem.largeTitleDisplayMode = .never
        
        [collectionView, errorStackView].forEach { view.addSubview($0) }
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
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

// MARK: - Picker Delegate
extension WishMomentsViewController: ImagePickerDelegate {
    func didSelect(image: UIImage) {
        let newSizeImage = resizeImage(image: image)
        viewModel.navigateAddHistory?(newSizeImage, nil, viewModel.wishVM)
    }
    
    func didSelect(url: URL) {
        guard let thumbnailImage = DB.Storage.thumbnailImageForFileUrl(url) else { return }
        let newSizeImage = resizeImage(image: thumbnailImage)
        viewModel.navigateAddHistory?(newSizeImage, url, viewModel.wishVM)
    }
}


// MARK: - Add History Delegate
extension WishMomentsViewController: AddHistoryDelegate {
    func addHistory(vm: HistoryViewModel) {
        fullHistoryViewModel.historyVMs.insert(vm, at: 0)
        fullHistoryViewModel.reloadDataParent?()
    }
}

// MARK: - Collection Delegate
extension WishMomentsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
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
        guard viewModel.wishVM != nil else { return 0 }
        return isShowAddCell ? fullHistoryViewModel.historyVMs.count + 1 : fullHistoryViewModel.historyVMs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isShowAddCell, indexPath.row == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: AddHistoryCell.cellIdentifier(), for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCell.cellIdentifier(), for: indexPath) as! HistoryCell
        cell.configure(viewModel: isShowAddCell ? fullHistoryViewModel.historyVMs[indexPath.row - 1] : fullHistoryViewModel.historyVMs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var index = IndexPath(row: indexPath.row, section: 0)
        if let wish = viewModel.wishVM, wish.isMyWish || wish.isIParticipate {
            index = IndexPath(row: indexPath.row - 1, section: 0)
        } else {
            
        }
        
        if indexPath.row == 0, let wish = viewModel.wishVM, wish.isMyWish || wish.isIParticipate {
            imagePicker.presentAlert(.customHistory)
        } else {
            viewModel.navigateHistory?(index)
            
            let indexPathWithAddCell = isShowAddCell ? indexPath.row - 1 : indexPath.row
            if fullHistoryViewModel.historyVMs.count - 1 == indexPathWithAddCell {
                fullHistoryViewModel.fetchHistories()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = Double((collectionView.bounds.width / 3) - 16)
        return .init(width: totalWidth, height: 165) // History Cell Size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12, left: 16, bottom: 60, right: 16)
    }
    
}
