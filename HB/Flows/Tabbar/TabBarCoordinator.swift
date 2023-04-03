

import UIKit

class TabBarCoordinator: BaseCoordinator {
    
    private var pushData: PushData?
    
    init(navigationController: UINavigationController, pushData: PushData?) {
        self.pushData = pushData
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        navigateTabBar()
        if let pushData = pushData {
            openPush(pushData)
        }
    }

    private func navigateTabBar() {
        let vc = TabBarController()
        
        let feedNavigationController = createNavigationController(icon: Icons.TabBar.home!, activeIcon: Icons.TabBar.homeActive!, tag: 0)
        let feedCoordinator = FeedCoordinator(navigationController: feedNavigationController)
        store(coordinator: feedCoordinator)
        feedCoordinator.start()
        
        let interestingNavigationController = createNavigationController(icon: Icons.TabBar.interesting!, activeIcon: Icons.TabBar.interestingActive!, tag: 1)
        let interestingCoordinator = InterestingCoordinator(navigationController: interestingNavigationController)
        store(coordinator: interestingCoordinator)
        interestingCoordinator.start()
        
        let addWishNavigationController = createNavigationController(icon: Icons.TabBar.add!, activeIcon: Icons.TabBar.addActive!, tag: 2)
        let addWishCoordinator = AddWishCoordinator(navigationController: addWishNavigationController)
        store(coordinator: addWishCoordinator)
        addWishCoordinator.start()
        
        let roomsNavigationController = createNavigationController(icon: Icons.TabBar.messages!, activeIcon: Icons.TabBar.messagesActive!, tag: 3)
        let roomsCoordinator = RoomsCoordinator(navigationController: roomsNavigationController)
        store(coordinator: roomsCoordinator)
        roomsCoordinator.start()
        
        let profileNavigationController = createNavigationController(icon: Icons.TabBar.profile!, activeIcon: Icons.TabBar.profileActive!, tag: 4)
        let profileCoordinator = ProfileCoordinator(navigationController: profileNavigationController)
        store(coordinator: profileCoordinator)
        profileCoordinator.start()
        
        profileCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: feedCoordinator)
            self?.free(coordinator: interestingCoordinator)
            self?.free(coordinator: addWishCoordinator)
            self?.free(coordinator: roomsCoordinator)
            self?.free(coordinator: profileCoordinator)
            self?.isCompleted?()
        }
        
        vc.viewControllers = [feedNavigationController,
                              interestingNavigationController,
                              addWishNavigationController,
                              roomsNavigationController,
                              profileNavigationController]
        
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func openPush(_ pushData: PushData) {
        guard let vc = navigationController.presentedViewController as? UITabBarController,
              let coordinator = childCoordinators[vc.selectedIndex] as? SharedCoordinatorProtocol & BaseCoordinator else { return }
        
        switch pushData.type {
        case .follow: coordinator.navigateProfile(uid: pushData.linkId)
        case .chat: coordinator.navigateMessage(roomId: pushData.linkId)
        case .request: coordinator.navigateRequests(wishId: pushData.linkId)
        case .wish: coordinator.navigateWish(wishId: pushData.linkId)
        }
    }
    
    func currentVC() -> UIViewController? {
        guard let vc = navigationController.presentedViewController as? UITabBarController else { return nil }
        return vc
    }
    
    private func createNavigationController(icon: UIImage, activeIcon: UIImage, tag: Int) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem.image = icon
        navigationController.tabBarItem.selectedImage = activeIcon
        navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: -10, bottom: -6, right: -10)
        navigationController.tabBarItem.tag = tag
        return navigationController
    }
}
