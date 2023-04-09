 

import UIKit
import SnapKit
import AVFoundation
import SVProgressHUD

class FullHistoryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Variables
    private let viewModel: FullHistoryViewModel
    private var isCameFromWish: Bool
    private var currentIndexPath: IndexPath
    private var players: [AVPlayer] = []
    
    // MARK: - Outlets
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: view.bounds.width, height: view.bounds.height)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FullHistoryCollectionViewCell.self, forCellWithReuseIdentifier: FullHistoryCollectionViewCell.cellIdentifier())
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.contentInsetAdjustmentBehavior = .never
        
        if #available(iOS 13.0, *) {
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        return collectionView
    }()
    
    // MARK: - LifeCycle
    init(viewModel: FullHistoryViewModel, currentIndexPath: IndexPath, isCameFromWish: Bool) {
        self.viewModel = viewModel
        self.currentIndexPath = currentIndexPath
        self.isCameFromWish = isCameFromWish
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIAndActions()
        viewModelBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        players.forEach({
            $0.removeObserver(self, forKeyPath: "timeControlStatus")
        })
        players = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.visibleCells.forEach{
            ($0 as? FullHistoryCollectionViewCell)?.play()
        }
    }
    
    // MARK: - Methods
    private func viewModelBinding() {
        viewModel.reloadDataFullHistory = { [self] in
            collectionView.reloadData()
        }
    }
    
    // MARK: - Actions
    @objc private func handleWish() {
        var historyVM: HistoryViewModel?
        
        collectionView.visibleCells.forEach{
            ($0 as? FullHistoryCollectionViewCell)?.pause()
            historyVM = ($0 as? FullHistoryCollectionViewCell)?.historyVM
        }
        
        if let historyVM = historyVM {
            actionWish(historyVM: historyVM)
        }
    }
    
    @objc private func handleBack() {
        self.collectionView.visibleCells.forEach {
            ($0 as? FullHistoryCollectionViewCell)?.pause()
        }
        showHUD(type: .dismiss)
        viewModel.navigateBack?()
    }
    
    // MARK: - Setup UI
    private func setupUIAndActions() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleBack))
        rightSwipe.direction = .right
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.delegate = self
        collectionView.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleWish))
        leftSwipe.direction = .left
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.delegate = self
        collectionView.addGestureRecognizer(leftSwipe)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: currentIndexPath, at: .top, animated: true)
    }
    
}

// MARK: - Collection Delegate
extension FullHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FullHistoryCollectionViewCell {
            cell.toggle()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.historyVMs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullHistoryCollectionViewCell.cellIdentifier(), for: indexPath) as! FullHistoryCollectionViewCell
        
        cell.configure(delegate: self, viewModel: viewModel.historyVMs[indexPath.row])
        
        if !viewModel.isLoading, viewModel.canLoadMore, indexPath.row == viewModel.historyVMs.count - 2 {
            viewModel.fetchHistories()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! FullHistoryCollectionViewCell).pause()
        showHUD(type: .dismiss)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let player = (cell as! FullHistoryCollectionViewCell).player {
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            players.append(player)
            
            (cell as! FullHistoryCollectionViewCell).play()
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {
                    if newStatus == .playing || newStatus == .paused {
                        SVProgressHUD.dismiss()
                    } else {
                        SVProgressHUD.show()
                    }
                }
            }
        }
    }
}

// MARK: - FullHistoryCell Delegate
extension FullHistoryViewController: FullHistoryCellDelegate {
    func actionBack() {
        self.handleBack()
    }
    
    func actionWish(historyVM: HistoryViewModel) {
        if !isCameFromWish {
            collectionView.visibleCells.forEach{
                ($0 as? FullHistoryCollectionViewCell)?.pause()
            }
            viewModel.navigateWish?(nil, historyVM.wishId)
        }
    }
    
    func actionProfile(historyVM: HistoryViewModel) {
        collectionView.visibleCells.forEach{
            ($0 as? FullHistoryCollectionViewCell)?.pause()
        }
        viewModel.navigateProfile?(historyVM.uid)
    }
    
    func actionMore(historyVM: HistoryViewModel) {
        
        let alert = UIAlertController(title: LocalizedText.wish.MOMENT_TITLE, message: LocalizedText.wish.MOMENT_MESSAGE, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: LocalizedText.wish.MOMENT_SHARE, style: .default, handler: { (_) in
            let vc = UIActivityViewController(activityItems: [URL(string: "https://wanty.io?history=" + historyVM.id)!], applicationActivities: [])
            self.present(vc, animated: true)
        }))
    
        if historyVM.uid == DB.Helper.uid {
            alert.addAction(UIAlertAction(title: LocalizedText.wish.MOMENT_DELETE, style: .destructive, handler: { (_) in
                self.handleDelete(historyVm: historyVM)
            }))
        } else {
            alert.addAction(UIAlertAction(title: LocalizedText.wish.MOMENT_COMPLAIN, style: .destructive, handler: { (_) in
                let reportObject = ReportObject(id: historyVM.id, type: ReportObjectType.history.rawValue, uid: historyVM.uid)
                self.viewModel.navigateReport?(reportObject)
            }))
        }
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func handleDelete(historyVm: HistoryViewModel) {
        let alert = UIAlertController(title: LocalizedText.alert.deleteWishTitle, message: historyVm.title, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedText.General.yes, style: .destructive, handler: { (_) in
            self.showHUD()
            self.viewModel.deleteHistory(id: historyVm.id, wishId: historyVm.wishId) { [self] (result) in
                switch result {
                case .success(_): showHUD(type: .success, text: LocalizedText.alert.deleteWishSuccess)
                case .failure(let error): showHUD(type: .error, text: "Error with deleting \(error.localizedDescription)")
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
