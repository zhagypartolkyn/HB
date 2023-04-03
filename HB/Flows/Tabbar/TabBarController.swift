 

import UIKit
import FirebaseFirestore
import FirebaseMessaging

class TabBarController: UITabBarController {
    
    // MARK: - Variables
    private var unreadRooms: Int = 0
    private var unreadActivities: Int = 0
    private var roomsListener: ListenerRegistration!
    private var activitiesListener: ListenerRegistration!
//    var coordinator: TabBarCoordinator?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupListeners()
        delegate = self
        
        if !DB.Helper.uid.isEmpty {
            Messaging.messaging().subscribe(toTopic: DB.Helper.uid) { _ in }
        }
    }
    
    deinit {
        self.roomsListener.remove()
        self.activitiesListener.remove()
    }
    
    // MARK: - Private Methods
    private func changeBadge() {
        guard let tabItems = self.tabBar.items else { return }
        
        let activitiesTabItem = tabItems[4]
        activitiesTabItem.badgeValue = unreadActivities == 0 ? nil : "\(unreadActivities)"
        
        let roomsTabItem = tabItems[3]
        roomsTabItem.badgeValue = unreadRooms == 0 ? nil : "\(unreadRooms)"
        
        UIApplication.shared.applicationIconBadgeNumber = unreadActivities + unreadRooms
    }
    
    private func setupListeners() {
        DB.listenModels(model: Room.self, query: Queries.Room.unreads()) { [self] (result) in
            switch result {
            case .success((let viewModels, _)): unreadRooms = viewModels.count
            case .failure(_): unreadRooms = 0
            }
            changeBadge()
        } captureListener: { (listener) in
            self.roomsListener = listener
        }
        
        DB.listenModels(model: Activity.self, query: Queries.Notification.unreads()) { [self] (result) in
            switch result {
            case .success((let viewModels, _)): unreadActivities = viewModels.count
            case .failure(_): unreadActivities = 0
            }
            changeBadge()
        } captureListener: { (listener) in
            self.activitiesListener = listener
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.tag)
    }
    
    // MARK: - Helpers
    private func setupTabBar() {
        tabBar.unselectedItemTintColor = UIColor.appColor(.textPrimary)
        tabBar.tintColor = UIColor.appColor(.primary)
        tabBar.shadowImage = nil
        tabBar.backgroundImage = nil
        tabBar.clipsToBounds = true
        tabBar.barTintColor = UIColor.appColor(.background)
        tabBar.layer.applyTabBarShadow()
    }
    
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let index = (children as NSArray).index(of: viewController)

        if selectedIndex == 0 && index == selectedIndex {
            let nav = children[0] as! UINavigationController
            let mainVC = nav.children[0] as! HomeViewController
            let vc1 = mainVC.viewControllers[1] as! CityViewController
            let vc2 = mainVC.viewControllers[2] as! CityMomentsViewController
            let vc0 = mainVC.viewControllers[0] as! TopWishesViewController

            if vc2.viewWillAppear, !vc2.isTableEmpty() {
                vc2.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            } else if !vc1.isTableEmpty(), vc1.viewWillAppear {
                vc1.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            } else if !vc0.isTableEmpty(), vc0.viewWillAppear {
                vc0.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }

        if selectedIndex == 1 && index == selectedIndex {
            let nav = children[1] as! UINavigationController
            let vc = nav.children[0] as! InterestingViewController
            vc.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }

        if selectedIndex == 3 && index == selectedIndex {
            let nav = children[3] as! UINavigationController
            let vc = nav.children[0] as! RoomsViewController
            if !vc.isTableEmpty() {
                vc.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }

        if selectedIndex == 4 && index == selectedIndex {
            let nav = children[4] as! UINavigationController
            let vc = nav.children[0] as! ProfileViewController
            vc.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }

        return !viewController.isMember(of: UIViewController.self)

    }
}
