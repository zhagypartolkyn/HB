//
 

import UIKit

class RoomBannedViewController: UICollectionViewController {

    // MARK: - Variables
    private let viewModel: RoomBannedViewModel
    private var roomViewModel: RoomViewModel
    private var deletedRoomUserViewModels: [RoomUserViewModel] = []
    private var batchService = BatchService()
    
    // MARK: - Outlets
    private var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 10)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    // MARK: - LifeCycle
    init(viewModel: RoomBannedViewModel, roomVM: RoomViewModel, deletedUsers: [RoomUserViewModel]) {
        self.viewModel = viewModel
        self.roomViewModel = roomVM
        self.deletedRoomUserViewModels = deletedUsers
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewSetup()
        view.backgroundColor = .white
        navigationItem.title = LocalizedText.messages.BLACKLIST
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    // MARK: - Private Methods
    private func collectionViewSetup() {
        collectionView?.register(RoomUserCell.self, forCellWithReuseIdentifier: RoomUserCell.cellIdentifier())
        collectionView?.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.appColor(.background)
    }
    
    // MARK: - Collection View Delegate
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deletedRoomUserViewModels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoomUserCell.cellIdentifier(), for: indexPath) as! RoomUserCell
        cell.delegate = self
        cell.configure(user: deletedRoomUserViewModels[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.navigateProfile?(deletedRoomUserViewModels[indexPath.item].uid)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
        layout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: RoomUserCell Delegate
extension RoomBannedViewController: RoomUserCellDelegate {
    func handleReturnOrDelete(roomUserVM: RoomUserViewModel) {
        let alert = UIAlertController(title: LocalizedText.messages.returnParticipantTitle, message: String.localizedStringWithFormat(LocalizedText.messages.returnParticipantMessage, roomUserVM.username), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: LocalizedText.General.yes, style: .default, handler: { (_: UIAlertAction!) in
            self.showHUD()
            
            DB.Helper.updateRoomUser(roomId: self.roomViewModel.id, wishId: self.roomViewModel.wishId, uid: roomUserVM.uid, request: nil, isDeleted: false, completionHandler: {
                self.deletedRoomUserViewModels = self.deletedRoomUserViewModels.filter{ $0.uid != roomUserVM.uid }
                self.collectionView.reloadData()
                self.showHUD(type: .dismiss)
            })
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: { (_: UIAlertAction!) in }))
        present(alert, animated: true, completion: nil)
    }
}
