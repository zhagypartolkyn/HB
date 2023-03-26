

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var appCoordinator : AppCoordinator!
    
    var pushData: PushData?
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.windowScene = windowScene
        
        // When you app is in closed state you should check for launch option in
        if let response = connectionOptions.notificationResponse {
            let userInfo = response.notification.request.content.userInfo
            
            if let type = userInfo["type"] as? String,
               let linkId = userInfo["linkId"] as? String,
               let pushType = PushType(rawValue: type) {
                
                pushData = PushData(type: pushType, linkId: linkId)
            }
        }
            
        
        let appCoordinator = AppCoordinator(window: window!, pushData: pushData)
        appCoordinator.start()
        self.appCoordinator = appCoordinator
        
        // Window clone in AppDelegate for ProgressHUD (Not working on center)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = window
        appDelegate.appCoordinator = appCoordinator
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        DB.Helper.isOnline(bool: false)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        DB.Helper.isOnline(bool: true)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        DB.Helper.isOnline(bool: false)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        DB.Helper.isOnline(bool: true)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        DB.Helper.isOnline(bool: false)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//            let url = userActivity.webpageURL,
//            let wishIdFromUrl = url.queryParams()["wish"]
////            let currentVC = UIApplication.topViewController()
//            else { return }
//
//        print("link")
////
////        let vc = WishController()
////        vc.id = wishIdFromUrl
////        currentVC.navigationController?.pushViewController(vc, animated: true)
    }

}
