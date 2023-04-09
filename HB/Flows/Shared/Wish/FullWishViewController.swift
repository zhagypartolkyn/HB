 

import UIKit
import FirebaseMessaging
import SnapKit
import Mantis

class FullWishViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: FullWishViewModel
    private let wishDetailViewModel: WishDetailViewModel
    private let fullHistoryViewModel: FullHistoryViewModel
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
        collectionView.register(HeaderWishCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderWishCollectionReusableView.identifier)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.cellIdentifier())
        return collectionView
    }()
    
    private lazy var wishButtonsStack = WishButtonsView(delegate: self)
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self, withVideo: true)
    private lazy var requestModalView = RequestModalView(delegate: self)
    
    // MARK: - LifeCycle
    init(viewModel: FullWishViewModel, wishDetailViewModel: WishDetailViewModel, fullHistoryViewModel: FullHistoryViewModel) {
        self.viewModel = viewModel
        self.wishDetailViewModel = wishDetailViewModel
        self.fullHistoryViewModel = fullHistoryViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModelBinding()
        viewModel.fetchWish()
    }
    
    // MARK: - Methods
    private func viewModelBinding() {
        fullHistoryViewModel.reloadDataParent = { [self] in
            collectionView.reloadData()
        }
        
        viewModel.roomUpdate = { [self] vm in
            collectionView.reloadData()
            print("reload")
        }
        
        viewModel.wishUpdate = { [self] vm in
            wishButtonsStack.configure(viewModel: vm)
            collectionView.reloadData()
            requestModalView.configureView(
                title: LocalizedText.wish.YOUR_REQUEST_WISH,
                subtitle: viewModel.wishVM.title,
                requestTitle: viewModel.wishVM.isGroupWish ? LocalizedText.wish.PARTICIPATE : LocalizedText.wish.FULFILL
            )
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)

        [collectionView, wishButtonsStack, requestModalView].forEach { view.addSubview($0) }
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        wishButtonsStack.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        requestModalView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}

// MARK: - Picker Delegate
extension FullWishViewController: ImagePickerDelegate {
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

// MARK: - AddHistory Delegate
extension FullWishViewController: AddHistoryDelegate {
    func addHistory(vm: HistoryViewModel) {
        fullHistoryViewModel.historyVMs.insert(vm, at: 0)
//        fullHistoryViewModel.reloadData([vm])
    }
}

// MARK: - RequestModalView Delegate
extension FullWishViewController: RequestModalViewDelegate {
    func handleSendButton(requestText: String) {
        showHUD()
        viewModel.createRequest(text: requestText) { [self] (result) in
            switch result {
            case .failure(let error):
                showHUD(type: .error, text: error.localizedDescription)
            case .success:
                showHUD(type: .success, text: LocalizedText.wish.REQUEST_SUCCESS)
                viewModel.fetchWish()
            }
        }
    }
}

// MARK: - Header Delegate
extension FullWishViewController: WishHeaderCellDelegate {
    func actionCover() {
        if !viewModel.wishVM.image.isEmpty {
            let vc = MediaViewController(image: viewModel.wishVM.image)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    func actionAvatar() {
        viewModel.navigateProfile?(viewModel.wishVM!.uid)
    }
}

// MARK: - Buttons Delegate
extension FullWishViewController: WishButtonsStackDelegate {
    func handleRequests() {
        if viewModel.wishVM.isMyWish {
            viewModel.navigateRequests?(viewModel.wishVM)
        }
    }
    
    func handleChat() {
        if viewModel.wishVM.isMyWish {
            if viewModel.wishVM.isGroupWish {
                viewModel.navigateMessage?(viewModel.wishVM.id)
            } else {
                viewModel.navigateRooms?(viewModel.wishVM)
            }
        } else {
            viewModel.navigateMessage?(viewModel.wishVM.id)
        }
    }
    
    func handleSendRequest() {
        requestModalView.showModal()
    }
    
    func handleWait() {
        showHUD(type: .info, text: LocalizedText.wish.WAIT_DESCRIPTION)
    }
}

// MARK: - Collection Delegate
extension FullWishViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let roomVM = viewModel.roomVM else { return 0 }
        return roomVM.participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.cellIdentifier(), for: indexPath) as! UserCell
        let uid = viewModel.roomVM?.participants[indexPath.row] ?? "uid"
        let user = viewModel.roomVM?.allUsers[uid]
        cell.configure(user?.thumb ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let roomVM = viewModel.roomVM else { return }
        let uid = roomVM.participants[indexPath.row]
        viewModel.navigateProfile?(uid)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 60, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     withReuseIdentifier: HeaderWishCollectionReusableView.identifier, for: indexPath) as! HeaderWishCollectionReusableView
        header.delegate = self
        if let wishVM = viewModel.wishVM {
            print("DEBUG: Yow sobaki ya Naruto uzumaki")
            header.configure(wishVM, count: viewModel.roomVM?.participants.count ?? 0)
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
}
