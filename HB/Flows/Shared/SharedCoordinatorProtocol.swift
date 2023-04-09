 

import UIKit

protocol SharedCoordinatorProtocol {}

extension SharedCoordinatorProtocol where Self: BaseCoordinator {
    
    // MARK: - Profile
    func navigateProfile(uid: String, isHideBackButton: Bool = false) {
        let vm = ProfileViewModel(uid: uid)
        let wishDetailViewModel: WishDetailViewModel = WishDetailViewModel()
        let vc = ProfileViewController(viewModel: vm, wishDetailViewModel: wishDetailViewModel, isHideBackButton: isHideBackButton)
        vm.navigateActivities = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigateActivities()
        }
        
        vm.navigateConnects = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateConnects(uid: uid)
        }
        
        vm.navigateMedia = { [weak self] (imageUrl) in
            guard let strongSelf = self else { return }
            strongSelf.navigateMedia(imageUrl: imageUrl)
        }
        
        vm.navigateEditProfile = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigateEditProfile()
        }
        
        vm.navigateFollow = { [weak self] (userVM, isFollowing) in
            guard let strongSelf = self else { return }
            strongSelf.navigateFollow(userVM: userVM, isFollowing: isFollowing)
        }
        
        vm.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId)
        }
        
        vm.navigateReport = { [weak self] (reportObject) in
            guard let strongSelf = self else { return }
            strongSelf.navigateReport(reportObject: reportObject)
        }
        
        vm.navigateSettings = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigateSettings()
        }
        
        vm.navigateRoot = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isCompleted?()
        }
        
        vm.navigateComplete = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateComplete(wishVM: wishVM)
        }
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Settings
    func navigateSettings() {
        let vm = SettingsViewModel()
        let vc = SettingsViewController(viewModel: vm)
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.dismiss(animated: true)
        }
        
        vm.navigateRoot = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.dismiss(animated: true)
            strongSelf.isCompleted?()
        }
        
        vc.hidesBottomBarWhenPushed = true
        navigationController.present(vc, animated: true)
    }
    
    // MARK: - Report
    func navigateReport(reportObject: ReportObject) {
        let vm = ReportViewModel()
        let vc = ReportViewController(viewModel: vm, reportObject: reportObject)
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.dismiss(animated: true)
        }
        
        vc.hidesBottomBarWhenPushed = true
        navigationController.present(vc, animated: true)
    }
    
    // MARK: - Edit Profile
    func navigateEditProfile() {
        let vc = EditProfileViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Follow
    func navigateFollow(userVM: UserViewModel, isFollowing: Bool) {
        let vm = FollowViewModel(userVM: userVM, isFirstActive: isFollowing)
        let vc = FollowViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Connects
    func navigateConnects(uid: String) {
        let vm = ProfileConnectsViewModel(uid: uid)
        let vc = ProfileConnectsViewController(viewModel: vm)
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Media
    func navigateMedia(imageUrl: String) {
        let vc = MediaViewController(image: imageUrl)
        navigationController.present(vc, animated: true)
    }
    
    // MARK: - Wish
    func navigateWish(wishVM: WishViewModel? = nil, wishId: String? = nil) {
        let query = Queries.History.wish(withId: (wishId ?? wishVM?.id)!)
        
        let vm = FullWishViewModel(wishVM: wishVM, wishId: wishId)
        let wishDetailViewModel: WishDetailViewModel = WishDetailViewModel()
        let fullHistoryViewModel = FullHistoryViewModel(query: query)
        let vc = WishScreenViewController(viewModel: vm, fullHistoryViewModel: fullHistoryViewModel, wishDetailViewModel: wishDetailViewModel)
        let momentsVC = WishMomentsViewController(viewModel: vm, fullHistoryViewModel: fullHistoryViewModel)
        vc.hidesBottomBarWhenPushed = true
        
        fullHistoryViewModel.navigateHistory = { [weak self] (currentIndexPath) in
            guard let strongSelf = self else { return }
            strongSelf.navigateHistory(viewModel: fullHistoryViewModel, currentIndexPath: currentIndexPath, isCameFromWish: true)
        }
        
        vm.navigateAddHistory = { [weak self] (image, url, wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateAddHistory(image: image, url: url, wishVM: wishVM, delegate: momentsVC)
        }
        
        vm.navigateHistory = { [weak self] (index) in
            guard let strongSelf = self else { return }
            strongSelf.navigateHistory(viewModel: fullHistoryViewModel, currentIndexPath: index, isCameFromWish: true)
            
        }
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        vm.navigateRequests = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateRequests(wishVM: wishVM)
        }
        
        vm.navigateMessage = { [weak self] (wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateMessage(wishId: wishId)
        }
        
        vm.navigateRooms = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateRooms(wishVM: wishVM)
        }
        
        vm.navigateReport = { [weak self] (reportObject) in
            guard let strongSelf = self else { return }
            strongSelf.navigateReport(reportObject: reportObject)
        }
        
        vm.navigateComplete = { [weak self] (wishVM) in
            guard let strongSelf = self else { return }
            strongSelf.navigateComplete(wishVM: wishVM)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateAddHistory(image: UIImage, url: URL?, wishVM: WishViewModel, delegate: AddHistoryDelegate) {
        let vm = AddHistoryViewModel(image: image, url: url, wish: wishVM)
        let vc = AddHistoryViewController(viewModel: vm, delegate: delegate)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateMessage(wishId: String? = nil, roomId: String? = nil) {
        let vm = MessageViewModel()
        let vc = MessageViewController(viewModel: vm, wishId: wishId, roomId: roomId)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        vm.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId)
        }
        
        vm.navigateRoomSettings = { [weak self] (roomVM, myNotifyStatus) in
            guard let strongSelf = self else { return }
            strongSelf.navigateRoomSettings(roomVM: roomVM, myNotifyStatus: myNotifyStatus)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Room Settings
    func navigateRoomSettings(roomVM: RoomViewModel, myNotifyStatus: Bool) {
        let vm = RoomSettingsViewModel()
        let vc = RoomSettingsViewController(viewModel: vm, roomVM: roomVM, myNotifyStatus: myNotifyStatus)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        vm.navigateBanned = { [weak self] (roomVM, deletedUsers) in
            guard let strongSelf = self else { return }
            strongSelf.navigateRoomBanned(roomVM: roomVM, deletedUsers: deletedUsers)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Banned
    func navigateRoomBanned(roomVM: RoomViewModel, deletedUsers: [RoomUserViewModel]) {
        let vm = RoomBannedViewModel()
        let vc = RoomBannedViewController(viewModel: vm, roomVM: roomVM, deletedUsers: deletedUsers)
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Rooms
    func navigateRooms(wishVM: WishViewModel? = nil) {
        let vm = RoomsViewModel(wishVM: wishVM)
        let wishDetailViewModel: WishDetailViewModel = WishDetailViewModel()
        let vc = RoomsViewController(viewModel: vm, wishDetailViewModel: wishDetailViewModel)
        
        vm.navigateMessage = { [weak self] (roomId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateMessage(roomId: roomId)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Requests
    func navigateRequests(wishVM: WishViewModel? = nil, wishId: String? = nil) {
        let vm = RequestViewModel()
        let vc = RequestsViewController(viewModel: vm, wishVM: wishVM, wishId: wishId)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        vm.navigateMessage = { [weak self] (wishId, roomId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateMessage(wishId: wishId, roomId: roomId)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - History
    func navigateHistory(viewModel: FullHistoryViewModel, currentIndexPath: IndexPath, isCameFromWish: Bool) {
        let vc = FullHistoryViewController(viewModel: viewModel, currentIndexPath: currentIndexPath, isCameFromWish: isCameFromWish)
        vc.hidesBottomBarWhenPushed = true
        
        viewModel.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        viewModel.navigateWish = { [weak self] (wishVM, wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateWish(wishVM: wishVM, wishId: wishId)
        }
        
        viewModel.navigateReport = { [weak self] (reportObject) in
            guard let strongSelf = self else { return }
            strongSelf.navigateReport(reportObject: reportObject)
        }
        
        viewModel.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Complete
    func navigateComplete(wishVM: WishViewModel) {
        let vm = CompleteViewModel(wishVM: wishVM)
        let vc = CompleteViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateBack = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Activities
    private func navigateActivities() {
        let vm = ActivitiesViewModel()
        let vc = ActivitiesViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vm.navigateProfile = { [weak self] (uid) in
            guard let strongSelf = self else { return }
            strongSelf.navigateProfile(uid: uid)
        }
        
        vm.navigateRequests = { [weak self] (wishId) in
            guard let strongSelf = self else { return }
            strongSelf.navigateRequests(wishId: wishId)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
}
