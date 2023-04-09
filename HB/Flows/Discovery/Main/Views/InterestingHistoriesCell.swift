

import UIKit
import SnapKit
import MapKit

class InterestingHistoriesCell: UITableViewCell {
    
    // MARK: - Variables
    private var viewModels: [HistoryViewModel] = []
    private var viewModel: InterestingViewModel?
    private var fullHistoryViewModel: FullHistoryViewModel?
    public var isError: Bool = false
    
    // MARK: - Outlets
    private let mainView = UIViewFactory()
        .background(color: UIColor.appColor(.background))
        .corner(radius: Constants.Radius.card)
        .build()
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: HistoryCell.cellIdentifier())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let titleLabel = UILabelFactory(text: LocalizedText.Interesting.HISTORY + " " + LocalizedText.Interesting.NEARBY)
        .text(color: UIColor.appColor(.textPrimary))
        .font(Fonts.Heading3)
        .build()
    
    private let subtitleLabel = UILabelFactory(text: LocalizedText.Interesting.POPULAR_HISTORY)
        .text(color: UIColor.appColor(.textSecondary))
        .font(Fonts.Secondary)
        .build()
    
    private let darkerView = UIViewFactory()
        .background(color: UIColor.appColor(.primary))
        .corner(radius: Constants.Radius.card, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        .alpha(0.5)
        .hide()
        .build()
    
    private let errorLabel = UILabelFactory(text: LocalizedText.Interesting.MOMENTS_ERROR)
        .font(Fonts.Heading3)
        .numberOf(lines: 0)
        .text(align: .center)
        .text(color: .white)
        .hide()
        .build()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    private func viewModelBinding() {
        guard let fullHistoryViewModel = fullHistoryViewModel else { return }
        fullHistoryViewModel.reloadDataParent = {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Public Methods
    public func configure(_ placeId: String?, viewModel: InterestingViewModel, fullHistoryViewModel: FullHistoryViewModel) {
        guard let placeId = placeId else { return }
        self.viewModel = viewModel
        self.fullHistoryViewModel = fullHistoryViewModel
        viewModelBinding()
        fullHistoryViewModel.query = Queries.History.place(withId: placeId)
        fullHistoryViewModel.fetchHistories()
    }
    
    private func showError(_ status: Bool) {
        darkerView.isHidden = !status
        errorLabel.isHidden = !status
        isError = status
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(mainView)
        mainView.layer.applyCardShadow()

        mainView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        [collectionView, titleLabel, subtitleLabel].forEach{ mainView.addSubview($0) }

        collectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
            make.top.equalToSuperview().inset(32)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().offset(24)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }

        subtitleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(16)
        }
        
        [darkerView, errorLabel].forEach { addSubview($0) }
        darkerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(mainView)
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(darkerView).inset(16)
            make.centerY.equalTo(darkerView)
        }
    }
    
}

// MARK: - Collection Delegate
extension InterestingHistoriesCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fullHistoryViewModel?.historyVMs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCell.cellIdentifier(), for: indexPath) as! HistoryCell
        if let fullHistoryViewModel = fullHistoryViewModel {
            cell.configure(viewModel: fullHistoryViewModel.historyVMs[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.navigateHistory?(viewModels, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 100, height: 150)
    }
}
