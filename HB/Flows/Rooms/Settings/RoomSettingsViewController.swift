//
//  RoomSettingsController.swift
 

import UIKit

class RoomSettingsViewController: UICollectionViewController {
    
    // MARK: - Variables
    private let viewModel: RoomSettingsViewModel
    private var roomViewModel: RoomViewModel
    private var isNotify: Bool
    
    // MARK: - Outlets
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 10)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    // MARK: - LifeCycle
    init(viewModel: RoomSettingsViewModel, roomVM: RoomViewModel, myNotifyStatus: Bool) {
        self.viewModel = viewModel
        roomViewModel = roomVM
        isNotify = myNotifyStatus
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewSetup()
        setupUI()
        viewModel.setupUsers(roomVM: roomViewModel)
                viewModelBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.observeRoom(id: roomViewModel.id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.leave()
    }
    
    // MARK: - Private Methods
    private func viewModelBinding() {
        viewModel.roomUpdate = { [self] (roomVM) in
            self.roomViewModel = roomVM
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Helpers
    private func collectionViewSetup() {
        collectionView?.register(RoomSettingsHeaderCell.self, forCellWithReuseIdentifier: RoomSettingsHeaderCell.cellIdentifier())
        collectionView?.register(RoomUserCell.self, forCellWithReuseIdentifier: RoomUserCell.cellIdentifier())
        collectionView?.collectionViewLayout = layout
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.appColor(.background)
        collectionView.backgroundColor = UIColor.appColor(.background)
        navigationItem.title = LocalizedText.profile.INFORMATION
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - CollectionView
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.roomUserViewModels.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoomSettingsHeaderCell.cellIdentifier(), for: indexPath) as! RoomSettingsHeaderCell
            cell.delegate = self
            cell.configure(viewModel: roomViewModel, myNotifyStatus: isNotify)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoomUserCell.cellIdentifier(), for: indexPath) as! RoomUserCell
            cell.delegate = self
            cell.configure(user: viewModel.roomUserViewModels[indexPath.row - 1])
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        viewModel.navigateProfile?(viewModel.roomUserViewModels[indexPath.row - 1].uid)
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

// MARK: - RoomSettingsHeaderCell Delegate
extension RoomSettingsViewController: RoomSettingsHeaderCellDelegate {
    func blackListAction() {
        viewModel.navigateBanned?(roomViewModel, viewModel.deletedRoomUserViewModels)
    }
    
    func switchAction(status: Bool) {
        Ref.Fire.notify(id: roomViewModel.id).updateData(["users.\(DB.Helper.uid)" : status])
    }
}

// MARK: - RoomUserCell Delegate
extension RoomSettingsViewController: RoomUserCellDelegate {
    func handleReturnOrDelete(roomUserVM: RoomUserViewModel) {
        let alert = UIAlertController(title: LocalizedText.messages.deleteParticipantTitle, message: String.localizedStringWithFormat(LocalizedText.messages.deleteParticipantMessage, roomUserVM.username), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: LocalizedText.General.yes, style: .default, handler: { (_: UIAlertAction!) in
            self.showHUD()
            
            DB.Helper.updateRoomUser(roomId: self.roomViewModel.id, wishId: self.roomViewModel.wishId, uid: roomUserVM.uid, request: nil, isDeleted: true) {
                self.viewModel.roomUserViewModels = self.viewModel.roomUserViewModels.filter{ $0.uid != roomUserVM.uid }
                self.roomViewModel.activeUsers = self.roomViewModel.activeUsers.filter { $0.value.uid != roomUserVM.uid }
                self.collectionView.reloadData()
                self.showHUD(type: .dismiss)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedText.General.cancel, style: .cancel, handler: { (_: UIAlertAction!) in }))
        present(alert, animated: true, completion: nil)
    }
}
